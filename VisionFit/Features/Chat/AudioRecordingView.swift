//
//  AudioRecordingView.swift
//  Edu Plus Admin
//
//  Created by Doniyorbek Ibrokhimov on 10/04/25.
//

import SwiftUI

struct AudioRecordingView: View {
    @EnvironmentObject private var speechRecognizer: SpeechRecognizer
    var showRecognizedTextLabel: Bool = true
    let tickAction: () -> Void
    
    private let iconColor = LinearGradient(
        colors: [Color(hex: "#192959"), Color(hex: "#3658BF")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var isTickDisabled: Bool {
        speechRecognizer.recognizedText.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if showRecognizedTextLabel {
                Text(speechRecognizer.recognizedText)
                    .truncationMode(.head)
            }
            
            HStack {
                Button {
                    speechRecognizer.stopRecording()
                } label: {
                    Image(systemName: "xmark")
                        .renderingMode(.template)
                        .foregroundStyle(iconColor)
                }
                .transition(
                    .asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity))
                )
                
                Spacer()
                
                VoiceWaveformView(speechRecognizer: speechRecognizer)
                
                Spacer()
                
                Button {
                    tickAction()
                } label: {
                    Image(uiImage: .checkmark)
                        .renderingMode(.template)
                        .foregroundStyle(iconColor)
                }
                .disabled(isTickDisabled)
                .opacity(isTickDisabled ? 0.5 : 1)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
            .background(Color.white)
            .clipShape(.capsule)
            //box-shadow: 0px 8px 18px 0px #243A7D1F;
            .shadow(color: Color(hex: "#243A7D").opacity(0.12), radius: 9, x: 0, y: 8)
        }
    }
}
