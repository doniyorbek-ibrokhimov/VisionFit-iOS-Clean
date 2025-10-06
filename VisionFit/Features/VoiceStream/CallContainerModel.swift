//
//  CallContainerModel.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 27/04/25.
//


import SwiftUI

import PipecatClientIOSGeminiLiveWebSocket
import PipecatClientIOS

class CallContainerModel: ObservableObject {
    
    @Published var voiceClientStatus: TransportState = TransportState.disconnected
    @Published var isInCall: Bool = false
    @Published var isBotReady: Bool = false
    
    @Published var isMicEnabled: Bool = false
    @Published var systemInstruction: String = ""
    
    @Published var toastMessage: String? = nil
    @Published var showToast: Bool = false
    var geminiAPIKey: String {
        guard let key = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] else {
            fatalError("GEMINI_API_KEY environment variable not set")
        }
        return key
    }
    
    @Published
    var remoteAudioLevel: Float = 0
    @Published
    var localAudioLevel: Float = 0
    
    var rtviClientIOS: RTVIClient?
    
    var isLoading: Bool {
        switch voiceClientStatus {
        case .disconnected, .initialized, .connected, .disconnecting:
            false
        case .initializing, .authenticating, .connecting, .ready, .error:
            true
        }
    }
    
    @Published var selectedMic: MediaDeviceId? = nil
    @Published var availableMics: [MediaDeviceInfo] = []
    
    private var cameraVM: VideoRecorderDelegate
    private var transport: GeminiLiveWebSocketTransport?
    
    init(cameraVM: VideoRecorderDelegate) {
        self.cameraVM = cameraVM
        // Changing the log level
        PipecatClientIOS.setLogLevel(.warn)
    }

    @MainActor
    func sendFeedback(_ feedback: String) {
        let message = "Give user this feedback: \(feedback)"
        sendMessage(message, role: .model)
    }

    
    
    @MainActor
    func connect() {
//        let geminiAPIKey = geminiAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
//        if(geminiAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty){
//            self.showError(message: "Need to provide a Gemini API key")
//            return
//        }
        
        let rtviClientOptions = RTVIClientOptions.init(
            enableMic: true,
            enableCam: true,
            params: .init(config: [])
        )
        
        let transport = GeminiLiveWebSocketTransport.init(options: rtviClientOptions, videoRecorder: cameraVM, modelConfig: modelConfig, apiKey: geminiAPIKey)
        
        self.transport = transport
        
        self.rtviClientIOS = RTVIClient.init(
            transport: transport,
            options: rtviClientOptions
        )
        self.rtviClientIOS?.delegate = self
        self.rtviClientIOS?.start() { result in
            switch result {
            case .failure(let error):
                self.showError(message: error.localizedDescription)
                self.rtviClientIOS = nil
            case .success():
                // Populate available devices list
                self.availableMics = self.rtviClientIOS?.getAllMics() ?? []
            }
        }
    }
    
    @MainActor
    func disconnect() {
        self.rtviClientIOS?.disconnect(completion: nil)
        self.rtviClientIOS?.release()
    }
    
    func showError(message: String) {
        self.toastMessage = message
        self.showToast = true
        // Hide the toast after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showToast = false
            self.toastMessage = nil
        }
    }
    
    @MainActor
    func toggleMicrophone() {
        self.rtviClientIOS?.enableMic(enable: !self.isMicEnabled) { result in
            switch result {
            case .success():
                self.isMicEnabled = self.rtviClientIOS?.isMicEnabled ?? false
            case .failure(let error):
                self.showError(message: error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func selectMic(_ mic: MediaDeviceId) {
        self.selectedMic = mic
        self.rtviClientIOS?.updateMic(micId: mic, completion: nil)
    }
    
    @Published var modelConfig: ModelConfig.Setup = .init(model: "models/gemini-2.0-flash-live-001",
                                                          generationConfig: .init(responseModalities: [.audio],
                                                                                  speechConfig: .init(voiceConfig: .init(prebuiltVoiceConfig: .init(voiceName: "Aoede")),
                                                                                                      languageCode: "en-US"), temperature: 0.3),
                                                          systemInstruction: .init(parts: [.init(thought: false, text: Constants.systemInstruction)], role: "model"),
                                                          outputAudioTranscription: .init())
    
    func sendExerciseData(exercise: String, description: String? = nil, repsCompleted: Int, totalReps: Int, currentRound: Int, totalRounds: Int) {
        // Create a simple readable message format instead of JSON
        var message = """
        Exercise progress update:
        Exercise: \(exercise)
        Completed: \(repsCompleted) of \(totalReps) reps
        Round: \(currentRound) of \(totalRounds)
        """
        
        // Add description if available
        if let exerciseDescription = description {
            message += "\nDescription: \(exerciseDescription)"
        }

        sendMessage(message, role: .model)
    }

    func sendExerciseFinishedMessage(exercise: String, description: String? = nil, repsCompleted: Int, totalReps: Int, currentRound: Int, totalRounds: Int) {
        let message = "User has finished the exercise: \(exercise)"
        sendMessage(message, role: .model)
    }
    
    func sendMessage(_ text: String, role: Role) {
        guard voiceClientStatus == .ready else { return }
        
        let message: ModelConfig.TextInput = .init(text: text, role: Role.user.rawValue)
        
        Task {
            do {
                try await transport?.sendMessage(message: message)
            } catch {
                print("Error sending text message: \(error.localizedDescription)")
            }
        }
    }
}

enum Role: String {
    case user, model
}

extension CallContainerModel:RTVIClientDelegate {
    
    private func handleEvent(eventName: String, eventValue: Any? = nil) {
        if let value = eventValue {
            print("Pipecat Demo, received event:\(eventName), value:\(value)")
        } else {
            print("Pipecat Demo, received event: \(eventName)")
        }
    }
    
    func onTransportStateChanged(state: TransportState) {
        Task { @MainActor in
            self.handleEvent(eventName: "onTransportStateChanged", eventValue: state)
            self.voiceClientStatus = state
            self.isInCall = ( state == .connecting || state == .connected || state == .ready || state == .authenticating )
        }
    }
    
    func onBotReady(botReadyData: BotReadyData) {
        Task { @MainActor in
            self.handleEvent(eventName: "onBotReady")
            self.isBotReady = true
        }
    }
    
    func onConnected() {
        Task { @MainActor in
            self.handleEvent(eventName: "onConnected")
            self.isMicEnabled = self.rtviClientIOS?.isMicEnabled ?? false
        }
    }
    
    func onDisconnected() {
        Task { @MainActor in
            self.handleEvent(eventName: "onDisconnected")
            self.isBotReady = false
        }
    }
    
    func onError(message: String) {
        Task { @MainActor in
            self.handleEvent(eventName: "onError", eventValue: message)
            self.showError(message: message)
        }
    }
    
    func onRemoteAudioLevel(level: Float, participant: Participant) {
        Task { @MainActor in
            self.remoteAudioLevel = level
        }
    }
    
    func onUserAudioLevel(level: Float) {
        Task { @MainActor in
            self.localAudioLevel = level
        }
    }
    
    func onAvailableMicsUpdated(mics: [MediaDeviceInfo]) {
        Task { @MainActor in
            self.availableMics = mics
        }
    }
    
    func onMicUpdated(mic: MediaDeviceInfo?) {
        Task { @MainActor in
            self.selectedMic = mic?.id
        }
    }
}
