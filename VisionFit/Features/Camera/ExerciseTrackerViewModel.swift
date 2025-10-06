//
//  ExerciseTrackerViewModel.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/12/24.
//

import AVFoundation
import Combine
import MLKit
import PipecatClientIOS
import SwiftUI

class ExerciseTrackerViewModel: NSObject, ObservableObject, VideoRecorderDelegate {
    let exerciseType: ExerciseType

    var streamContinuation: AsyncStream<Data>.Continuation?

    func streamVideo() -> AsyncStream<Data> {
        return AsyncStream { continuation in
            self.streamContinuation = continuation
        }
    }

    init(exerciseType: ExerciseType) {
        self.exerciseType = exerciseType
        super.init()

        resetManagedLifecycleDetectors(activeDetector: currentDetector)
        setUpCaptureSessionOutput()
        setUpCaptureSessionInput()
    }

    @Published var isUsingFrontCamera: Bool = true
    @Published var currentDetector: Detector = .pose
    @Published var poseOverlays: [PoseOverlay] = []  // A model to represent overlay data

    private let detectors: [Detector] = [.pose, .poseAccurate]
    private var poseDetector: PoseDetector?
    private var lastDetector: Detector?
    private let sessionQueue = DispatchQueue(label: "SessionQueue")

    // AVFoundation properties
    let captureSession = AVCaptureSession()
    private var lastFrame: CMSampleBuffer?

    // Exercise tracking properties
    @Published var isSameLine: Bool = false
    @Published var isDoingLeftHand = false
    @Published var rightHandCount = 0
    @Published var leftHandCount = 0
    @Published var squatCount = 0

    var isFinished: Bool {
        return rightHandCount == maxHandCount && leftHandCount == maxHandCount
    }

    var isSquatFinished: Bool {
        return squatCount == maxSquatCount
    }

    let maxHandCount = 10
    let maxSquatCount = 10
    let thresholdAngle: CGFloat = 90
    let sameLineThreshold: CGFloat = 15
    let newRepThreshold: CGFloat = 20
    let shoulderAnkleThreshold: CGFloat = 15
    let hipKneeThreshold: CGFloat = 5
    @Published var isNewRep = false
    @Published var isNewSquat = false
    @Published var inSquatPosition = false
    @Published var armRaisesFeedback: String?

    // MARK: - Camera Setup

    private func setUpCaptureSessionOutput() {
        sessionQueue.async {
            self.captureSession.stopRunning()
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .medium

            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
            ]
            output.alwaysDiscardsLateVideoFrames = true
            let outputQueue = DispatchQueue(label: "VideoDataOutputQueue")
            output.setSampleBufferDelegate(self, queue: outputQueue)

            guard self.captureSession.canAddOutput(output) else {
                print("Failed to add capture session output.")
                return
            }
            self.captureSession.addOutput(output)
            self.captureSession.commitConfiguration()
        }
    }

    private func setUpCaptureSessionInput() {
        sessionQueue.async {
            let cameraPosition: AVCaptureDevice.Position = self.isUsingFrontCamera ? .front : .back
            guard let device = self.captureDevice(forPosition: cameraPosition) else {
                print("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            do {
                self.captureSession.beginConfiguration()
                for input in self.captureSession.inputs {
                    self.captureSession.removeInput(input)
                }

                let input = try AVCaptureDeviceInput(device: device)
                guard self.captureSession.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                self.captureSession.addInput(input)
                self.captureSession.commitConfiguration()
            }
            catch {
                print("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }

    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        return discoverySession.devices.first { $0.position == position }
    }

    // MARK: - Session Control

    func startSession() {
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async {
            self.captureSession.stopRunning()
        }
    }

    func switchCamera() {
        isUsingFrontCamera.toggle()
        removeDetectionAnnotations()
        setUpCaptureSessionInput()
    }

    func selectDetector(_ detector: Detector) {
        currentDetector = detector
        removeDetectionAnnotations()
    }

    // MARK: - Pose Detection

    private func resetManagedLifecycleDetectors(activeDetector: Detector) {
        if activeDetector == self.lastDetector { return }

        // Clear old detector
        switch self.lastDetector {
        case .pose, .poseAccurate:
            self.poseDetector = nil
        default:
            break
        }

        // Initialize new detector
        switch activeDetector {
        case .pose, .poseAccurate:
            let options =
                activeDetector == .pose ? PoseDetectorOptions() : AccuratePoseDetectorOptions()
            self.poseDetector = PoseDetector.poseDetector(options: options)
        }

        self.lastDetector = activeDetector
    }

    func angle(
        firstLandmark: PoseLandmark,
        midLandmark: PoseLandmark,
        lastLandmark: PoseLandmark
    ) -> CGFloat {
        let lastLandmarkY = lastLandmark.position.y
        let lastLandmarkX = lastLandmark.position.x

        let midLandmarkY = midLandmark.position.y
        let midLandmarkX = midLandmark.position.x

        let firstLandmarkY = firstLandmark.position.y
        let firstLandmarkX = firstLandmark.position.x

        let radians: CGFloat =
            atan2(lastLandmarkY - midLandmarkY, lastLandmarkX - midLandmarkX)
            - atan2(firstLandmarkY - midLandmarkY, firstLandmarkX - midLandmarkX)

        var degrees = (radians * 180.0) / .pi
        degrees = abs(degrees) * 2  // Angle should never be negative
        if degrees > 180.0 {
            degrees = 360.0 - degrees  // Always get the acute representation of the angle
        }
        return degrees
    }

    private func detectPose(
        in image: MLImage,
        width: CGFloat,
        height: CGFloat,
        orientation: UIImage.Orientation
    ) {
        guard let poseDetector = poseDetector else { return }
        do {
            let poses = try poseDetector.results(in: image)
            if poses.isEmpty {
                print("Pose detector returned no results.")
                DispatchQueue.main.async {
                    self.armRaisesFeedback = "Stand in the center of the view, make sure your whole body is visible"
                    self.poseOverlays = []
                }
            }
            else {
                poseDetector.process(image) { [weak self] detectedPoses, error in
                    guard error == nil else {
                        // Error.
                        
                        print("\nPose detection error: \(error!.localizedDescription)")
                        return
                    }
                    guard let detectedPoses = detectedPoses, !detectedPoses.isEmpty else {
                        // No pose detected.
                        print("\nNo pose detected.")
                        return
                    }

                    // Success. Get pose landmarks here.
                    for pose in detectedPoses {
                        // Convert pose points to overlay data
                        let overlays = detectedPoses.map { pose -> PoseOverlay in
                            // Convert VisionPoints to normalized points here
                            // For demonstration, we'll store the raw pose landmarks.
                            // In a real app, you'd transform these to the screen coordinates.
                            return PoseOverlay(
                                pose: pose,
                                width: width,
                                height: height,
                                orientation: orientation
                            )
                        }

                        DispatchQueue.main.async {
                            self?.armRaisesFeedback = nil
                            self?.poseOverlays = overlays
                            // Update pose overlays with detected form
                        }

                        switch self?.exerciseType {
//                        case .squat:
//                            self.detectSquats(pose: pose)
                        case .bicepCurls:
                            self?.detectArmRaises(pose: pose)
                        default:
                            // Default case for other exercise types
                            break
                        }
                    }
                }
            }
        }
        catch let error {
            print("Failed to detect poses with error: \(error.localizedDescription).")
        }
    }

    private func detectSquats(pose: Pose) {
        // Get needed landmarks for squat detection
        let leftShoulderLandmark = pose.landmark(ofType: .leftShoulder)
        let rightShoulderLandmark = pose.landmark(ofType: .rightShoulder)
        let leftHipLandmark = pose.landmark(ofType: .leftHip)
        let rightHipLandmark = pose.landmark(ofType: .rightHip)
        let leftKneeLandmark = pose.landmark(ofType: .leftKnee)
        let rightKneeLandmark = pose.landmark(ofType: .rightKnee)
        let leftAnkleLandmark = pose.landmark(ofType: .leftAnkle)
        let rightAnkleLandmark = pose.landmark(ofType: .rightAnkle)

        // Print all landmark coordinates for debugging
        print("\n--- Landmark Coordinates ---")
        print(
            "Left Shoulder: x=\(leftShoulderLandmark.position.x), y=\(leftShoulderLandmark.position.y)"
        )
        print(
            "Right Shoulder: x=\(rightShoulderLandmark.position.x), y=\(rightShoulderLandmark.position.y)"
        )
        print("Left Hip: x=\(leftHipLandmark.position.x), y=\(leftHipLandmark.position.y)")
        print("Right Hip: x=\(rightHipLandmark.position.x), y=\(rightHipLandmark.position.y)")
        print("Left Knee: x=\(leftKneeLandmark.position.x), y=\(leftKneeLandmark.position.y)")
        print("Right Knee: x=\(rightKneeLandmark.position.x), y=\(rightKneeLandmark.position.y)")
        print("Left Ankle: x=\(leftAnkleLandmark.position.x), y=\(leftAnkleLandmark.position.y)")
        print("Right Ankle: x=\(rightAnkleLandmark.position.x), y=\(rightAnkleLandmark.position.y)")

        print("---------------------------")

        // Check if shoulders are aligned with ankles (x-axis)
        let shoulderAnkleAlignment =
            abs(leftShoulderLandmark.position.y - leftAnkleLandmark.position.y)
            < shoulderAnkleThreshold
            && abs(rightShoulderLandmark.position.y - rightAnkleLandmark.position.y)
                < shoulderAnkleThreshold

        // Check if knees are lower than hips (y-axis)
        let kneesBelowHips =
            leftKneeLandmark.position.x > leftHipLandmark.position.x
            && rightKneeLandmark.position.x > rightHipLandmark.position.x

        // Determine if in squat position
        let currentSquatPosition = kneesBelowHips && shoulderAnkleAlignment

        DispatchQueue.main.async {
            self.isSameLine = currentSquatPosition
        }

        print(
            "\nSquat detection - Shoulder alignment: \(shoulderAnkleAlignment), Knees below hips: \(kneesBelowHips)"
        )
        print(
            "In squat position: \(currentSquatPosition), Previous position: \(self.inSquatPosition)"
        )

        let yAxis = [
            leftShoulderLandmark.position.y,
            leftHipLandmark.position.y,
            leftKneeLandmark.position.y,
            rightShoulderLandmark.position.y,
            rightHipLandmark.position.y,
            rightKneeLandmark.position.y,
        ]

        if let max = yAxis.max(), let min = yAxis.min(),
            max - min < self.shoulderAnkleThreshold
        {
            self.isNewRep = true
        }

        if isNewRep && !kneesBelowHips {
            squatCount += 1
            isNewRep = false
        }
    }

    private func detectArmRaises(pose: Pose) {
        if self.isDoingLeftHand {
//            print("\n#######################")

            let leftShoulderLandmark = pose.landmark(ofType: .leftShoulder)
            let leftElbowLandmark = pose.landmark(ofType: .leftElbow)
            let leftWristLandmark = pose.landmark(ofType: .leftWrist)

            //same line of left shoulder, hip and knee with left shoulder, elbow
            let leftHipLandmark = pose.landmark(ofType: .leftHip)
            let leftKneeLandmark = pose.landmark(ofType: .leftKnee)

            let yAxis = [
                leftShoulderLandmark.position.y,
                leftElbowLandmark.position.y,
                leftHipLandmark.position.y,
                leftKneeLandmark.position.y,
            ]

            if let max = yAxis.max(), let min = yAxis.min() {
                self.isSameLine = max - min < self.sameLineThreshold
            }

            let leftHandAngle = self.angle(
                firstLandmark: leftElbowLandmark,
                midLandmark: leftShoulderLandmark,
                lastLandmark: leftWristLandmark
            )

//            print("\nLeft Shoulder Angle: \(leftHandAngle)")

            if self.leftHandCount < self.maxHandCount {
                if leftHandAngle < self.newRepThreshold && self.isSameLine {
                    self.isNewRep = true
                }
                else if leftHandAngle > self.thresholdAngle && self.isNewRep && self.isSameLine {
                    self.leftHandCount += 1
                    self.isNewRep = false
                }
            }
            else {
                self.isDoingLeftHand = false
            }

        }
        else {
//            print("\n***********************")
            let rightShoulderLandmark = pose.landmark(ofType: .rightShoulder)
            let rightElbowLandmark = pose.landmark(ofType: .rightElbow)
            let rightWristLandmark = pose.landmark(ofType: .rightWrist)

            //same line of right shoulder, hip and knee with right shoulder, elbow
            let rightHipLandmark = pose.landmark(ofType: .rightHip)
            let rightKneeLandmark = pose.landmark(ofType: .rightKnee)

            let yAxis = [
                rightShoulderLandmark.position.y,
                rightElbowLandmark.position.y,
                rightHipLandmark.position.y,
                rightKneeLandmark.position.y,
            ]

            if let max = yAxis.max(), let min = yAxis.min() {
                self.isSameLine = max - min < self.sameLineThreshold
            }

            let rightHandAngle = self.angle(
                firstLandmark: rightElbowLandmark,
                midLandmark: rightShoulderLandmark,
                lastLandmark: rightWristLandmark
            )
//            print("\nRight Shoulder Angle: \(rightHandAngle)")

            if self.rightHandCount < self.maxHandCount {
                if rightHandAngle < self.newRepThreshold && self.isSameLine {
                    self.isNewRep = true
                }
                else if rightHandAngle > self.thresholdAngle && self.isNewRep && self.isSameLine {
                    self.rightHandCount += 1
                    self.isNewRep = false
                }
            }
            else {
                self.isDoingLeftHand = true
            }
        }
    }

    private func removeDetectionAnnotations() {
        DispatchQueue.main.async {
            self.poseOverlays = []
        }
    }
}

extension ExerciseTrackerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let activeDetector = self.currentDetector
        resetManagedLifecycleDetectors(activeDetector: activeDetector)

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer.")
            return
        }

        lastFrame = sampleBuffer
        let orientation =
            self.isUsingFrontCamera ? UIImage.Orientation.leftMirrored : UIImage.Orientation.right

        //Send image to PoseDetector
        if exerciseType == .bicepCurls {
            sendImageToPoseDetector(
                sampleBuffer: sampleBuffer,
                imageBuffer: imageBuffer,
                orientation: orientation,
                activeDetector: activeDetector
            )
        }

        //Send image to LLM
        sendImageToLLM(imageBuffer: imageBuffer)
    }

    private func sendImageToPoseDetector(
        sampleBuffer: CMSampleBuffer,
        imageBuffer: CVImageBuffer,
        orientation: UIImage.Orientation,
        activeDetector: Detector
    ) {
        guard let mlImage = MLImage(sampleBuffer: sampleBuffer) else {
            print("Failed to create MLImage.")
            return
        }
        mlImage.orientation = orientation

        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))

        switch activeDetector {
        case .pose, .poseAccurate:
            detectPose(
                in: mlImage,
                width: imageWidth,
                height: imageHeight,
                orientation: orientation
            )
        }
    }

    private func sendImageToLLM(imageBuffer: CVImageBuffer) {
        guard let imageData = createImageData(from: imageBuffer) else {
            print("Failed to convert frame to image data")
            return
        }
        streamContinuation?.yield(imageData)
    }

    private func createImageData(from pixelBuffer: CVPixelBuffer) -> Data? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        let context = CIContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard
            let cgImage = context.createCGImage(
                ciImage,
                from: ciImage.extent,
                format: .RGBA8,
                colorSpace: colorSpace
            )
        else {
            return nil
        }

        let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
        let imageData = uiImage.jpegData(compressionQuality: 0.5)

        //        DispatchQueue.main.async {
        //            if let imageData {
        //                self.currentImage = UIImage(data: imageData)
        //            }
        //        }

        return imageData
    }
}

// MARK: - Detector and PoseOverlay Models

public enum Detector: String, CaseIterable {
    case pose = "Pose Detection"
    case poseAccurate = "Pose Detection, accurate"
}

struct PoseOverlay: Identifiable {
    let id = UUID()
    let pose: Pose
    let width: CGFloat
    let height: CGFloat
    let orientation: UIImage.Orientation
    // Additional computed properties can go here to transform
    // pose landmarks into on-screen coordinates.
}

struct PoseOverlayView: UIViewRepresentable {
    let pose: Pose
    let bounds: CGRect
    let lineWidth: CGFloat
    let dotRadius: CGFloat

    func makeUIView(context: Context) -> UIView {
        return UIUtilities.createPoseOverlayView(
            forPose: pose,
            inViewWithBounds: bounds,
            lineWidth: lineWidth,
            dotRadius: dotRadius
        ) { position in
            // Transform Vision coordinates to view coordinates
            CGPoint(x: position.x, y: position.y)
        }
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if needed
    }
}
