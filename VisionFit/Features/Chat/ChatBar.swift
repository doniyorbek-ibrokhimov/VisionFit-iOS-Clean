//
//  ChatBar.swift
//  Edu Plus Admin
//
//  Created by Doniyorbek Ibrokhimov on 08/04/25.
//

import SwiftUI

struct ChatBar: View {
    var isTopicSelectionDisabled: Bool = false
    var isNavigatedFromHome: Bool
    var namespace: Namespace.ID? = nil

    @StateObject private var speechRecognizer = SpeechRecognizer()
    @EnvironmentObject private var vm: ChatViewModel
    @State private var showChat = false
    @State private var showChatbarSheet = false
    @State private var transcribedText: String = ""
    @State private var typedText: String = ""
    @Namespace private var barNamespace
    @FocusState private var isFocused: Bool

    //background: linear-gradient(141.31deg, #192959 19.92%, #3658BF 92.22%);
    private let placeholderColor = LinearGradient(
        colors: [Color(hex: "#192959"), Color(hex: "#3658BF")],
        startPoint: .leading,
        endPoint: .trailing
    )

    //border-image-source: linear-gradient(141.31deg, #192959 19.92%, #3658BF 92.22%);
    private let iconColor = LinearGradient(
        colors: [Color(hex: "#192959"), Color(hex: "#3658BF")],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        VStack(spacing: 6) {
            if speechRecognizer.isRecording {
                AudioRecordingView(tickAction: {
                    let transcribedText = speechRecognizer.recognizedText
                    speechRecognizer.stopRecording()
                    if vm.isChatActive {
                        vm.sendMessage(transcribedText)
                    } else {
                        self.transcribedText = transcribedText
                        showChat = true
                    }
                })
                .environmentObject(speechRecognizer)
                .matchedGeometryEffect(id: "bottom_bar", in: barNamespace)
            }
            else {
//                topicsView
//                    .transition(
//                        .asymmetric(
//                            insertion: .move(edge: .bottom).combined(with: .opacity),
//                            removal: .move(edge: .bottom).combined(with: .opacity)
//                        )
//                    )
                
                searchBar
                    .matchedGeometryEffect(id: "bottom_bar", in: barNamespace)
            }
        }
        .frame(maxWidth: .infinity)
        // non ui affecting modifiers
        .sheet(isPresented: $showChatbarSheet) {
            ChatBarSheet(showChat: $showChat, typedText: $typedText)
                .presentationCornerRadius(24)
                .presentationDetents([.fraction(0.95)])
                .environmentObject(vm)
                .environmentObject(speechRecognizer)
        }
        .animation(.easeInOut, value: speechRecognizer.isRecording)
        .navigationDestination(isPresented: $showChat) {  // navigate only from home view
            if let namespace {
                ChatView(selectedTopic: $vm.selectedTopic, transcribedText: $transcribedText, typedText: $typedText)
                    .navigationAllowDismissalGestures(.none)
                    .navigationTransition(
                        .zoom(sourceID: "chat", in: namespace)
                    )
                    .environmentObject(vm)  
            }
        }
    }

    private var topicsView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Topic.allCases, content: topicItem)
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, -16)
        .scrollIndicators(.hidden)
    }

    private func topicItem(_ topic: Topic) -> some View {
        Button {
            withAnimation(.easeInOut) {
                vm.selectedTopic = topic

                // send message
                vm.sendMessage(topic.localizedTitle)
            }
        } label: {
            HStack(alignment: .center, spacing: 10) {
                topic.icon
                    .renderingMode(.template)
                    //background: linear-gradient(117.35deg, #192959 3.95%, #3658BF 108.48%);
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#192959"), Color(hex: "#3658BF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(10)
                    .background(Color(hex: "#EEF1F8"))
                    .clipShape(.circle)

                Text(topic.description)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.primaryDark)
            }
            .padding(.leading, 2)
            .padding(.trailing, 14)
            .padding(.vertical, 2)
            .background(.white)
            .clipShape(.capsule)
            .overlay(
                Capsule()
                    .stroke(Color(hex: "#F4F4F4"), lineWidth: 1)
            )
        }
        .disabled(isTopicSelectionDisabled)
        .opacity(isTopicSelectionDisabled ? 0.5 : 1)
    }

    @ViewBuilder
    private var searchBar: some View {
        if isNavigatedFromHome {
            Button {
                showChatBarSheet()
            } label: {
                textFieldContent
            }
        } else {
            textFieldContent
        }
    }
    
    private var placeholder: some View {
        Text("Ask \(Constants.voiceAI)")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(placeholderColor)
    }

    private var textFieldContent: some View {
        HStack(alignment: .center) {
            Color.clear
                .frame(width: 1, height: 1)
            
            Spacer()

            if isNavigatedFromHome {
                placeholder
            } else {
                TextField("", text: $typedText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 12)
                    .foregroundColor(.primaryDark)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .textFieldStyle(PlainTextFieldStyle())
                    .overlay(alignment: .center) {
                        if typedText.isEmpty {
                            placeholder
                        }
                    }
                    .focused($isFocused)
            }

            Spacer()

            if !typedText.isEmpty {
                Button {
                    vm.sendMessage(typedText)
                    typedText = ""
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .renderingMode(.template)
                        .foregroundStyle(iconColor)
                }
            } else {
                Button {
                    speechRecognizer.startRecording()
                } label: {
                    Image(systemName: "mic.fill")
                        .renderingMode(.template)
                        .foregroundStyle(iconColor)
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(Color.white)
        .clipShape(.capsule)
        //box-shadow: 0px 8px 18px 0px #243A7D1F;
        .shadow(color: Color(hex: "#243A7D").opacity(0.12), radius: 9, x: 0, y: 8)
    }
    
    func showChatBarSheet() {
        showChatbarSheet = true
    }
}
