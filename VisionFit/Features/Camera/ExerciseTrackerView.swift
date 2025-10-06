//
//  ExerciseTrackerView.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/12/24.
//

import AVFoundation
import SwiftUI
import QuickPoseCore
import MLKit
import QuickPoseSwiftUI

struct ExerciseTrackerView: View {
    @StateObject var viewModel: ExerciseTrackerViewModel
    @StateObject private var callManager: CallContainerModel
    @State private var lastFeedbackTime: Date = .distantPast

    let exerciseType: ExerciseType

    init(exerciseType: ExerciseType) {
        let viewModel: ExerciseTrackerViewModel = .init(exerciseType: exerciseType)
        
        self.exerciseType = exerciseType
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._callManager = StateObject(wrappedValue: .init(cameraVM: viewModel))
    }
    
    private var quickPose = QuickPose(sdkKey: Constants.quickPoseSDKKey) // register for your free key at https://dev.quickpose.ai
    @State private var overlayImage: UIImage?
    @State private var feedbackText: String? = nil
    @State private var counter = QuickPoseThresholdCounter()
    @State private var currentCount: Int?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            // Camera Preview
            exerciseView
                .environmentObject(viewModel)
            
            // Top Navigation
            HStack {
                // Back Button
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
                }

                Spacer()
                
                // Disconnect call button
                Button("Disconnect") {
                    callManager.disconnect()
                }
                
                Button("Connect") {
                    callManager.connect()
                }

                Spacer()

                // Camera Switch Button
                Button(action: { viewModel.switchCamera() }) {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Circle().fill(Color.black.opacity(0.6)))
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal)
        .navigationBarHidden(true)
        .onAppear {
//            callManager.connect()
            viewModel.startSession()
        }
        .onChange(of: callManager.voiceClientStatus, { oldValue, newValue in
            switch newValue {
            case .ready:
                callManager.sendExerciseData(exercise: exerciseType.title, description: exerciseType.description, repsCompleted: 0, totalReps: 10, currentRound: 1, totalRounds: 1)
            default:
                break
            }
        })
        .onChange(of: feedbackText) { _, newFeedback in
            guard let feedbackText = newFeedback else { return }
            
            let currentTime = Date()
            if currentTime.timeIntervalSince(lastFeedbackTime) >= 3.0 {
                callManager.sendFeedback(feedbackText)
                lastFeedbackTime = currentTime
            }
        }
        .onChange(of: viewModel.armRaisesFeedback) { _, newValue in
            guard let newValue, callManager.voiceClientStatus == .ready, !viewModel.isFinished else { return }
            
            let currentTime = Date()
            if currentTime.timeIntervalSince(lastFeedbackTime) >= 3.0 {
                callManager.sendFeedback(newValue)
                lastFeedbackTime = currentTime
            }
        }
        .onChange(of: viewModel.leftHandCount) { _, newValue in
           guard callManager.voiceClientStatus == .ready else { return }    
            callManager.sendExerciseData(exercise: "Right" + exerciseType.title, repsCompleted: newValue, totalReps: 10, currentRound: 1, totalRounds: 1)
        }
        .onChange(of: viewModel.rightHandCount) { _, newValue in
            guard callManager.voiceClientStatus == .ready else { return }
            callManager.sendExerciseData(exercise: "Left" + exerciseType.title, repsCompleted: newValue, totalReps: 10, currentRound: 1, totalRounds: 1)
        }
        .onChange(of: viewModel.isFinished) { _, newValue in
            if newValue {
                callManager.sendExerciseFinishedMessage(exercise: exerciseType.title, description: exerciseType.description, repsCompleted: 10, totalReps: 10, currentRound: 1, totalRounds: 1)
            }
        }
//        .onChange(of: viewModel.isSameLine) { _, newValue in
//            guard callManager.voiceClientStatus == .ready else { return }
//            let currentTime = Date()
//            if currentTime.timeIntervalSince(lastFeedbackTime) >= 3.0 {
//                if newValue {
//                    callManager.sendFeedback("Good job, hold this position. You are doing great!")
//                } else {
//                    // Wait 3 seconds before sending the feedback message
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                        callManager.sendFeedback("Your body alignment needs adjustment. Try to keep your shoulders, hips, and legs in a straight line for proper form.")
//                    }
//                    return
//                    // callManager.sendFeedback("Your body alignment needs adjustment. Try to keep your shoulders, hips, and legs in a straight line for proper form.")
//                }
//
//                lastFeedbackTime = currentTime
//            }
//        }
        .onDisappear {
            callManager.disconnect()
            viewModel.stopSession()
        }
    }

    @ViewBuilder
    private var exerciseView: some View {
        switch exerciseType {
        case .bicepCurls:
            CameraPreview(session: viewModel.captureSession)
                                .onAppear { viewModel.startSession() }
                                .onDisappear { viewModel.stopSession() }
                                .ignoresSafeArea()
                                .padding(.horizontal, -16)
            
            VStack {
                HStack(spacing: 16) {
                    CountView(
                        count: viewModel.leftHandCount,
                        side: "Left hand",
                        isVisible: viewModel.isDoingLeftHand || viewModel.isFinished,
                        isActive: viewModel.isDoingLeftHand
                    )

                    Spacer()

                    CountView(
                        count: viewModel.rightHandCount,
                        side: "Right hand",
                        isVisible: !viewModel.isDoingLeftHand || viewModel.isFinished,
                        isActive: !viewModel.isDoingLeftHand
                    )
                }
                
                // Bounding Box - Redesigned with smoother animations
                ZStack {
                    // Outer border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    viewModel.isSameLine ? Color.green.opacity(0.7) : Color.orange.opacity(0.7),
                                    viewModel.isSameLine ? Color.green.opacity(0.9) : Color.orange.opacity(0.9),
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(
                            width: UIScreen.main.bounds.size.width * 0.7,
                            height: UIScreen.main.bounds.size.height * 0.6
                        )
                        .offset(y: 20)

                    // Inner subtle highlight
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    viewModel.isSameLine ? Color.green.opacity(0.3) : Color.orange.opacity(0.3),
                                    viewModel.isSameLine ? Color.green.opacity(0.5) : Color.orange.opacity(0.5),
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 8
                        )
                        .frame(
                            width: UIScreen.main.bounds.size.width * 0.7,
                            height: UIScreen.main.bounds.size.height * 0.6
                        )
                        .offset(y: 20)
                        .opacity(0.5)
//                        .animation(.easeInOut(duration: 0.3), value: viewModel.isSameLine)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//            poseEstimationView(for: [.fitness(.squats)])
//            poseEstimationView(for: [.fitness(.bicepCurls)])
            
        
//        default:
//            // For now, default to squat tracking for other exercise types
//            // TODO: Add appropriate tracking for each exercise type
//            poseEstimationView(for: [.fitness(.squats)])
        case .pushUps:
            poseEstimationView(for: [.fitness(.pushUps)])
        case .jumpingJacks:
            poseEstimationView(for: [.fitness(.jumpingJacks)])
        case .sumoSquats:
            poseEstimationView(for: [.fitness(.sumoSquats)])
        case .lunges:
            poseEstimationView(for: [.fitness(.lunges(side: .right))])
        case .sitUps:
            poseEstimationView(for: [.fitness(.sitUps)])
        case .cobraWings:
            poseEstimationView(for: [.fitness(.cobraWings)])
        case .plank:
            poseEstimationView(for: [.fitness(.plank)])
        case .plankStraightArm:
            poseEstimationView(for: [.fitness(.plankStraightArm)])
        case .legRaises:
            poseEstimationView(for: [.fitness(.legRaises)])
        case .gluteBridge:
            poseEstimationView(for: [.fitness(.gluteBridge)])
        case .overheadDumbbellPress:
            poseEstimationView(for: [.fitness(.overheadDumbbellPress)])
        case .vUps:
            poseEstimationView(for: [.fitness(.vUps)])
        case .lateralRaises:
            poseEstimationView(for: [.fitness(.lateralRaises)])
        case .frontRaises:
            poseEstimationView(for: [.fitness(.frontRaises)])
        case .hipAbductionStanding:
            poseEstimationView(for: [.fitness(.hipAbductionStanding(side: .right))])
        case .sideLunges:
            poseEstimationView(for: [.fitness(.sideLunges(side: .right))])
        case .bicepCurlsSingleArm:
            poseEstimationView(for: [.fitness(.bicepCurlsSingleArm(side: .right))])
        case .squat:
            poseEstimationView(for: [.fitness(.squats)])
        }
    }
    
    private func poseEstimationView(for features: [QuickPose.Feature]) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                QuickPoseCameraView(useFrontCamera: viewModel.isUsingFrontCamera, delegate: quickPose)
                QuickPoseOverlayView(overlayImage: $overlayImage)
            }
            .overlay(alignment: .center) {
                if let feedbackText = feedbackText {
                    Text(feedbackText)
                        .font(.system(size: 26, weight: .semibold)).foregroundColor(.white).multilineTextAlignment(.center)
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color("AccentColor").opacity(0.8)))
                        .padding(.bottom, 40)
                }
            }
            .onAppear {
                quickPose.start(features: features, onFrame: { status, image, features, feedback, landmarks in
                    overlayImage = image
                    switch status {
                    case .success:
                        if let result = features.values.first  {
                            let counterState = counter.count(result.value)
                            let count = counterState.count
                            feedbackText = nil
                            if currentCount != count {
                                currentCount = count
                                callManager.sendExerciseData(exercise: exerciseType.title, repsCompleted: count, totalReps: 10, currentRound: 1, totalRounds: 2)
                            }
//                            feedbackText = "\(count) \(self.exerciseType.title)"
                            
                            
                        } else if let feedback = feedback.values.first, feedback.isRequired  {
                            feedbackText = feedback.displayString
                        } else {
                            feedbackText = nil
                        }
                    case .noPersonFound:
                        feedbackText = "Stand in view";
                    case .sdkValidationError:
                        feedbackText = "Be back soon";
                    }
                })
            }.onDisappear {
                quickPose.stop()
            }
            .frame(width: geometry.size.width)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct CountView: View {
    let count: Int
    let side: String
    let isVisible: Bool
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(side)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                }
            }

            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.black.opacity(0.6))
        .foregroundColor(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.green : Color.clear, lineWidth: 2)
        )
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}
