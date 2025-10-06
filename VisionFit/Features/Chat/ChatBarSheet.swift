//
//  ChatBarSheet.swift
//  Edu Plus Admin
//
//  Created by Doniyorbek Ibrokhimov on 10/04/25.
//

import SwiftUI

struct ChatBarSheet: View {
    var placeholder: LocalizedStringKey = "ask-placeholder"
    @Binding var showChat: Bool
    @Binding var typedText: String
    
    @State var  messageText: String = ""
    @FocusState private var isFocused
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: ChatViewModel
    @EnvironmentObject private var speechRecognizer: SpeechRecognizer
    
    private var isSendButtonDisabled: Bool {
        messageText.isEmpty || vm.isAssistantResponding
    }
    
    private let iconColor = LinearGradient(
        colors: [Color(hex: "#192959"), Color(hex: "#3658BF")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        chatbarSheet
            .animation(.easeInOut, value: speechRecognizer.isRecording)
            .onAppear {
                isFocused = true
            }
            .onChange(of: speechRecognizer.isRecording, { oldValue, newValue in
                if newValue {
                    isFocused = false
                }
            })
            .onChange(of: speechRecognizer.recognizedText) { oldValue, newValue in
                if !newValue.isEmpty {
                    messageText = speechRecognizer.recognizedText
                }
            }
    }
    
    var text: Binding<String> {
        let a = Binding(
            get: { messageText },
            set: { newValue in
                messageText = newValue
            }
        )
        
        return a
    }
    
    
    @ViewBuilder
    private var chatbarSheet: some View {
        //background: linear-gradient(141.31deg, #192959 19.92%, #3658BF 92.22%);
        let placeholderColor = LinearGradient(gradient: Gradient(colors: [Color(hex: "#192959"), Color(hex: "#3658BF")]), startPoint: .leading, endPoint: .trailing)
        
        VStack(alignment: .leading, spacing: 16) {
            Button {
                // Close action
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .foregroundStyle(Color.primaryDark)
                    .padding(10)
                    .background(Color.gray)
                    .clipShape(.circle)
            }
            
            TextField("", text: text, axis: .vertical)
                .lineLimit(1...5)
                .foregroundColor(.primaryDark)
                .overlay(alignment: .leading) {
                    if messageText.isEmpty {
                        Text(placeholder)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(placeholderColor)
                            .opacity(0.5)
                    }
                }
                .focused($isFocused)
            
            Divider()
            
            // suggestions
            // VStack(alignment: .leading, spacing: 16) {
            
            // }
            
            Spacer()
            
            if speechRecognizer.isRecording {
                AudioRecordingView(showRecognizedTextLabel: false, tickAction: {
                    let recognizedText = speechRecognizer.recognizedText
                    speechRecognizer.stopRecording()
                    typedText = recognizedText
                    dismiss()
                    showChat = true
                })
            } else {
                HStack {
                    Button {
                        speechRecognizer.startRecording()
                    } label: {
                        Image(systemName: "mic.fill")
                            .renderingMode(.template)
                    }
                    
                    Spacer()
                    
                    // simple text
                    Button {
                        typedText = messageText
                        dismiss()
                        showChat = true
                    } label: {
                        Image(systemName: "paperplane")
                            .font(.system(size: 24, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .clipShape(.capsule)
                    }
                    .disabled(isSendButtonDisabled)
                    .opacity(isSendButtonDisabled ? 0.5 : 1.0)
                }
            }
        }
        .padding()
    }
}

