//
//  AssistantMessageView.swift
//  Edu Plus Admin
//
//  Created by Doniyorbek Ibrokhimov on 15/04/25.
//

import SwiftUI

struct AssistantMessageView: View {
    let message: Message

    @State private var isExpanded = true
    @EnvironmentObject private var vm: ChatViewModel
    @State private var isPlaying = false
    
    @State private var isLoadingTranscript: Bool = false

    var body: some View {
        HStack(alignment: .bottom) {
            Image(systemName: "person")

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    audioButton(content: message.content)

                    VoiceWaveformViewStaticAnimation(isPlaying: isPlaying)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)

                    Button {
                        withAnimation(.easeInOut) {
                            isExpanded.toggle()
                        }
                    } label: {
                        if isExpanded {
                            Image(systemName: "chevron.up")
                                .renderingMode(.template)
                                .foregroundStyle(Color.primaryGray)
                                .transition(
                                    .asymmetric(
                                        insertion:
                                            .move(edge: .top)
                                            .combined(with: .scale)
                                            .combined(with: .opacity),
                                        removal:
                                            .move(edge: .top)
                                            .combined(with: .scale)
                                            .combined(with: .opacity)
                                    )
                                )
                        }
                        else {
                            Image(systemName: "chevron.down")
                                .renderingMode(.template)
                                .foregroundStyle(Color.primaryGray)
                                .transition(
                                    .asymmetric(
                                        insertion:
                                            .move(edge: .bottom)
                                            .combined(with: .scale)
                                            .combined(with: .opacity),
                                        removal:
                                            .move(edge: .bottom)
                                            .combined(with: .scale)
                                            .combined(with: .opacity)
                                    )
                                )
                        }
                    }
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        MarkdownText(message.content)
                            .textSelection(.enabled)
                        
                        ShareLink(item: message.content) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .medium))
                                .tint(.black)
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        )
                    )
                }
            }
            .padding(16)
            .cornerRadius(16)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#DAD8E1"), lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: vm.streamer.isPlaying) { oldValue, newValue in
            guard vm.currentlyPlayingMessage == message else { return }
            isPlaying = newValue
        }
        .onChange(of: vm.currentlyPlayingMessage) { oldValue, newValue in
            isPlaying = newValue == message
        }
    }

    @ViewBuilder
    private func audioButton(content: String) -> some View {
        if isPlaying {
            Button {
                vm.currentlyPlayingMessage = nil
                vm.streamer.stop()
            } label: {
                Image(systemName: "pause")
                    .renderingMode(.template)
                    .foregroundStyle(Color.blue.gradient)
                    .padding(10)
                    .clipShape(.circle)
                    .overlay {
                        Circle()
                            .stroke(Color.blue.gradient.opacity(0.5), lineWidth: 1)
                    }
            }
        }
        else {
            Button {
                vm.currentlyPlayingMessage = message
                vm.streamer.startStreaming(text: content.stripMarkdown())
            } label: {
                Image(systemName: "play")
                    .renderingMode(.template)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color.blue.gradient)
                    .clipShape(.circle)
            }
        }
    }
}
