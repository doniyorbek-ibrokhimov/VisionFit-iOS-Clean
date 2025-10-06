//
//  ChatView.swift
//  Edu Plus Admin
//
//  Created by Doniyorbek Ibrokhimov on 07/04/25.
//

import SwiftUI

struct ChatView: View {
    // MARK: - Stored Properties
    @Binding var selectedTopic: Topic?
    @Binding var transcribedText: String
    @Binding var typedText: String
    
    @State private var messageText: String =
        "make me correations of attendance VS gpa of schools and give me comparisions"
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var vm: ChatViewModel

    //background: linear-gradient(110.69deg, #729CF8 -0.71%, #A366C9 88.25%);
    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "#729CF8"), Color(hex: "#A366C9")]),
        startPoint: .leading,
        endPoint: .trailing
    )

    @State private var chatBarSize: CGSize?
    @State private var navbarSize: CGSize?
    let gradientA = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "#192959"), Color(hex: "#3658BF")]),
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            switch vm.state {
            case .loading:
                ProgressView()
            case .loaded, .initial, .empty:
                messagesScrollView
            case .error(let error):
                Text(error)
            }
            
            ChatBar(isTopicSelectionDisabled: vm.isAssistantResponding, isNavigatedFromHome: false)
        }
        .navigationBarBackButtonHidden()
//        .overlay {
//            VStack {
//                Spacer()
//                ChatBar(isTopicSelectionDisabled: vm.isAssistantResponding, isNavigatedFromHome: false)
//                    .readSize($chatBarSize)
//                    .ignoresSafeArea(edges: .bottom)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .ignoresSafeArea()
//        }
        .overlay(alignment: .top) {
            navBar
        }
        // non ui affecting modifiers
        .task {
            // Load chat sessions when view appears
            // await vm.fetchSessions(userId: "this_is_test_user")
            await vm.createSession()
            if let selectedTopic {
                sendTopic(selectedTopic)
            } else if !transcribedText.isEmpty {
                sendTranscribedText($transcribedText)
            } else if !typedText.isEmpty {
                sendTranscribedText($typedText)
            }
        }
        .onChange(of: vm.messages) { _, messages in
            vm.state = messages.isEmpty ? .empty : .loaded
        }
        .onAppear {
            vm.isChatActive = true
        }
        .onDisappear {
            vm.cancelTasks()
            vm.isChatActive = false
        }
        .animation(.easeInOut, value: vm.messages.count)
        .environmentObject(vm)
    }

    private func sendTopic(_ topic: Topic?) {
        if let topic {
            vm.sendMessage(topic.localizedTitle)
            selectedTopic = nil
        }
    }
    
    private func sendTranscribedText(_ text: Binding<String>) {
        vm.sendMessage(text.wrappedValue)
        text.wrappedValue = ""
    }

    // MARK: - View Components
    private var navBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .renderingMode(.template)
                    .foregroundColor(.primaryGray)
            }

            Spacer()
        }
        .overlay {
            Image(systemName: "bubble")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(gradientA)
                .aspectRatio(contentMode: .fit)
                .frame(height: 16)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .readSize($navbarSize)
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            chatBotIcon
                .padding(.bottom, 30)

            Text("chat-hi")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text("u-can-ask")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }

    private var chatBotIcon: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 140, height: 140)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .cyan.opacity(0.7),
                            .blue.opacity(0.8),
                            .purple.opacity(0.7),
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 70
                    )
                )
                .frame(width: 120, height: 120)
                .blur(radius: 5)
        }
    }

    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Spacer(minLength: navbarSize?.height)
                
                LazyVStack(spacing: 12) {
                    ForEach(vm.messages) { message in
                        messageView(for: message)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.primaryDark)
                            .padding(.bottom, message == vm.messages.last ? 12 : 0)
                            .id(message)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .move(edge: .bottom).combined(with: .opacity)
                                )
                            )
                    }
                  
                    if vm.isAssistantResponding {
                        MessageLoadingView()
                            .id("placeholder")
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .move(edge: .bottom).combined(with: .opacity)
                                )
                            )
                    }
                }
                .padding()
                .padding(.bottom, chatBarSize?.height)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: vm.messages.last) { _, lastMessage in
                scrollToMessage(proxy: proxy, message: lastMessage)
            }
            .onAppear {
                scrollToMessage(proxy: proxy, message: vm.messages.last)
            }
            .onChange(of: vm.isAssistantResponding) { _, _ in
                withAnimation(.easeInOut) {
                    proxy.scrollTo("placeholder", anchor: .top)
                }
            }
        }
    }

    private func scrollToMessage(proxy: ScrollViewProxy, message: Message?) {
        withAnimation(.easeInOut) {
            proxy.scrollTo(message, anchor: .top)
        }
    }

    private var inputField: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                TextField("", text: $messageText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .foregroundColor(.primaryDark)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .textFieldStyle(PlainTextFieldStyle())
                    .overlay(alignment: .center) {
                        if messageText.isEmpty {
                            Text("ask")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(gradient)
                        }
                    }

                Button(action: {
                    // Send message action
                    vm.sendMessage(messageText)
                    messageText = ""
                }) {
                    Image(systemName: "send")
                }
                .disabled(messageText.isEmpty || vm.isAssistantResponding)
                .opacity(messageText.isEmpty || vm.isAssistantResponding ? 0.5 : 1.0)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        // background: #FFFFFF66;
        //  .background(
        //      Color.white
        //          .blur(radius: 8) // Apply blur only to the background
        //  )
        .padding(.top, 12)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func messageView(for message: Message) -> some View {
        let background = Color(hex: "#F4F4F4")

        switch message.role {
        case .user:
            MarkdownText(message.content)
                .textSelection(.enabled)
                .padding(12)
                .background(background)
                .cornerRadius(16)
                .frame(maxWidth: .infinity, alignment: .trailing)
        case .assistant:
            AssistantMessageView(message: message)
                .environmentObject(vm)
        }
    }
}
