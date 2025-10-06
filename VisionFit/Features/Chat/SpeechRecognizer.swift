//
//  SpeechRecognizer.swift
//  Edu Plus Admin
//
//  Created by nigga on 09/04/25.
//

import SwiftUI
import Speech
import AVFoundation
import Accelerate

class SpeechRecognizer: ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var audioLevels: [Float] = Array(repeating: 0, count: 30)

    private var levelTimer: Timer?

    func startRecording() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to reset AVAudioSession for recording: \(error)")
        }
        
        guard let speechRecognizer = SFSpeechRecognizer(locale: AppCore.shared.language.locale), speechRecognizer.isAvailable else { return }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.inputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
            self.updateAudioLevels(buffer: buffer)
        }

        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Audio engine failed to start: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isRecording = false
        recognizedText = ""
    }

    private func updateAudioLevels(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)

        // Use Accelerate to compute RMS
        var rms: Float = 0.0
        vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frameLength))

        let avgPower = 20 * log10(rms + .leastNonzeroMagnitude) // avoid log(0)

        let clampedPower = max(-60, min(-10, avgPower))
        var normalizedPower = (clampedPower + 60) / 50 // 0 to 1
        normalizedPower = pow(normalizedPower, 2.0)

        DispatchQueue.main.async {
            let smoothed = self.audioLevels.last.map {
                $0 * 0.7 + normalizedPower * 0.3
            } ?? normalizedPower

            self.audioLevels.append(smoothed)
            if self.audioLevels.count > 30 {
                self.audioLevels.removeFirst()
            }
        }
    }
}

struct VoiceWaveformView: View {
    @ObservedObject var speechRecognizer: SpeechRecognizer

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(Array(speechRecognizer.audioLevels.enumerated()), id: \.offset) { index, level in
                Capsule()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "#192959"), Color(hex: "#3658BF")]), startPoint: .top, endPoint: .bottom))
                    .frame(width: 4, height: CGFloat(level) * 40 + 4)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 25), value: level)
            }
        }
        .animation(.easeOut(duration: 0.1), value: speechRecognizer.audioLevels)
    }
}

struct VoiceWaveformViewStaticAnimation: View {
    let isPlaying: Bool
    @State private var audioLevels: [Float] = Array(repeating: 0.1, count: 30)
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(Array(audioLevels.enumerated()), id: \.offset) { index, level in
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#192959"), Color(hex: "#3658BF")]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4, height: CGFloat(level) * 32 + 4)
                    .animation(.interpolatingSpring(stiffness: 200, damping: 25), value: level)
            }
        }
        .onReceive(timer) { _ in
            guard isPlaying else { return }
            withAnimation {
                // Generate new random levels between 0 and 1
                audioLevels = (0..<30).map { _ in Float.random(in: 0.3...1.0) }
            }
        }
    }
}
