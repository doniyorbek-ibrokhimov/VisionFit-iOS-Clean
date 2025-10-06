//
//  VoiceStreamView.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 21/04/25.
//

import SwiftUI

struct VoiceStreamView: View {
    // MARK: - Properties
    
    @StateObject private var callManager: CallContainerModel
    @StateObject private var cameraVM: CameraViewModel
    
    init() {
        let cameraVM: CameraViewModel = .init()
        
        _callManager = .init(wrappedValue: .init(cameraVM: cameraVM))
        _cameraVM = .init(wrappedValue: cameraVM)
    }
    @State private var showConnectionSheet = false
    @State private var selectedExercise = "Arm Raises"
    @State private var currentReps = 0
    @State private var totalReps = 8
    @State private var currentRound = 1
    @State private var totalRounds = 2
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            content
        }
        .task {
            // You can perform initial setup here if needed
        }
    }
    
    // MARK: - UI Components
    
    private var content: some View {
        VStack(spacing: 20) {
            Button("clean") {
                callManager.disconnect()
            }
            
            // Title and status
            titleSection

            // Camera preview
            CameraPreview(session: cameraVM.captureSession)
                    .onAppear { cameraVM.startSession() }
                    .onDisappear { cameraVM.stopSession() }
                    .frame(width: 300, height: 300)
            
            // Exercise controls
            exerciseControlsSection
            
            // Connection controls
            connectionSection
            
            // Microphone toggle
            microphoneSection
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
        .sheet(isPresented: $showConnectionSheet) {
            connectionSettingsSheet
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("VisionFit AI Trainer")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack {
                Circle()
                    .fill(connectionStateColor)
                    .frame(width: 12, height: 12)
                
                Text(callManager.voiceClientStatus.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top)
    }
    
    private var connectionSection: some View {
        VStack(spacing: 15) {
            Button {
                if callManager.voiceClientStatus == .ready {
                    callManager.disconnect()
                } else {
                    callManager.connect()
                }
            } label: {
                Text(callManager.voiceClientStatus == .ready ? "Disconnect" : "Connect to Trainer")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        callManager.voiceClientStatus == .ready ? Color.red : Color.blue
                    )
                    .cornerRadius(10)
            }
            .disabled(callManager.isLoading)
            
            Button {
                showConnectionSheet = true
            } label: {
                Label("Advanced Connection Settings", systemImage: "gear")
                    .font(.footnote)
            }
        }
        .padding(.horizontal)
    }
    
    private var microphoneSection: some View {
        Button {
            callManager.toggleMicrophone()
        } label: {
            Label(
                callManager.isMicEnabled ? "Mute Microphone" : "Unmute Microphone",
                systemImage: callManager.isMicEnabled ? "mic.fill" : "mic.slash.fill"
            )
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                callManager.isMicEnabled ? Color.green : Color.gray
            )
            .cornerRadius(10)
        }
        .disabled(callManager.voiceClientStatus != .connected)
        .padding(.horizontal)
    }
    
    private var connectionSettingsSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Model Settings")) {
                    TextField("System Instructions", text: $callManager.systemInstruction)
                }
            }
            .navigationTitle("Advanced Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showConnectionSheet = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var connectionStateColor: Color {
        switch callManager.voiceClientStatus {
        case .connected: return .green
        case .connecting: return .yellow
        case .disconnected: return .red
            
        default: return .white
        }
    }
    
    private var exerciseControlsSection: some View {
        VStack(spacing: 12) {
            Text("Exercise Progress")
                .font(.headline)
            
            if callManager.voiceClientStatus == .ready {
                // Exercise selection
                Picker("Exercise", selection: $selectedExercise) {
                    Text("Arm Raises").tag("Arm Raises")
                    Text("Squats").tag("Squats")
                    Text("Push-ups").tag("Push-ups")
                    Text("Lunges").tag("Lunges")
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
                
                // Reps controls
                HStack {
                    Text("Reps: \(currentReps) / \(totalReps)")
                    
                    Spacer()
                    
                    Button(action: {
                        if currentReps > 0 {
                            currentReps -= 1
//                            updateExerciseData()
                        }
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.title2)
                    }
                    
                    Button(action: {
                        if currentReps < totalReps {
                            currentReps += 1
//                            updateExerciseData()
                        }
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                    }
                }
                
                // Rounds controls
                HStack {
                    Text("Round: \(currentRound) / \(totalRounds)")
                    
                    Spacer()
                    
                    Button(action: {
                        if currentRound > 1 {
                            currentRound -= 1
//                            updateExerciseData()
                        }
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.title2)
                    }
                    
                    Button(action: {
                        if currentRound < totalRounds {
                            currentRound += 1
//                            updateExerciseData()
                        }
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                    }
                }
                
                // Send exercise data button
                Button(action: updateExerciseData) {
                    HStack {
                        Image(systemName: "arrow.up.doc.fill")
                        Text("Update AI Trainer")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 8)
            } else {
                Text("Connect to the AI trainer to track exercises")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.black.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func updateExerciseData() {
        callManager.sendExerciseData(
            exercise: selectedExercise,
            repsCompleted: currentReps,
            totalReps: totalReps,
            currentRound: currentRound,
            totalRounds: totalRounds
        )
    }
}
