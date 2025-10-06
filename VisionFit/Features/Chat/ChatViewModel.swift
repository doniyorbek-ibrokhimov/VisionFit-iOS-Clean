//
//  ChatViewModel.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/04/25.
//

import Combine
import Foundation
import SwiftUI

final class ChatViewModel: SuperViewModel {
    // MARK: - Properties
    @Published var messages: [Message] = []
    @Published var isAssistantResponding = false
    @Published var streamer = ElevenLabsStreamer()
    @Published var currentlyPlayingMessage: Message?
    @Published var isChatActive = false
    @Published var selectedSession: ChatSession?
    @Published var sessions: [ChatSession] = []
    @Published var selectedTopic: Topic?
    
    private var cancellables = Set<AnyCancellable>()
    
    // Use a single task variable for the current chat task
    private var chatTask: Task<Void, Never>?
    
    func cancelTasks() {
        print("Canceling tasks...")
        
        // Cancel the current chat task
        if let chatTask = chatTask {
            print("Cancelling current chat task")
            chatTask.cancel()
            self.chatTask = nil
        }
        
        // Reset state
        isAssistantResponding = false
        
        // Clear messages and selected session
        sessions = []
        selectedSession = nil
        messages = []
        streamer.stop()
    }

    var formattedDate: String {
        Date().formatted(.dateTime.hour().month(.wide).day().year())
    }
    
    override init() {
        super.init()
        // forward changes from streamer to this ViewModel
        streamer.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Fetches all chat sessions for the given user ID
    /// - Parameter userId: The ID of the user to fetch sessions for
//    func fetchSessions(userId: String) async {
//        state = .loading
//
//        do {
//            sessions = try await ChatService().getSession(for: userId)
//            if let firstSession = sessions.first {
//                selectSession(firstSession)
//            }
//        }
//        catch {
//            state = .error(error.localizedDescription)
//        }
//    }
    
    /// Selects a chat session and loads its messages
    /// - Parameter session: The chat session to select
    func selectSession(_ session: ChatSession) {
        selectedSession = session
        messages = session.messages
    }
    
    /// Creates a new chat session with the given title and user ID
    /// - Parameters:
    ///   - title: The title for the new chat session
    ///   - userId: The user ID who is creating the session
    /// - Returns: The newly created ChatSession
    func createSession(title: String = "New Session \(Int.random(in: 1...1000000))", userId: String = "this_is_test_user") async {
        do {
            let newSession = try await ChatService().createSession(title: title, userId: userId)
            
            // Add the new session to our list and select it
            await MainActor.run {
                sessions.append(newSession)
                selectSession(newSession)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    /// Sends a new message in the current chat session
    /// - Parameter text: The text content of the message
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("No message text")
            return
        }
        
        guard let selectedSession else {
            print("No selected session")
            return
        }
        
        // Create a user message and add it to the messages array
        let userMessage = Message(
            role: .user,
            content: text,
            id: UUID().uuidString,
            createdAt: Date()
        )
        
        self.messages.append(userMessage)
        
        // Cancel any existing task before starting a new one
        chatTask?.cancel()
        
        // Create a new task for sending the message
        chatTask = Task {
            await sendMessageToServer(id: selectedSession.id, text: text)
        }
    }
    
    private func sendMessageToServer(id: String, text: String) async {
        // Set the loading state
        await MainActor.run {
            isAssistantResponding = true
        }
        
        do {
            // Check for cancellation before making the request
            try Task.checkCancellation()
            
            // Get response from the server using the chat endpoint
            let response = try await ChatService().chat(sessionId: id, message: text, imgUrl: nil)
            
            // Check for cancellation after the request but before updating the UI
            try Task.checkCancellation()
            
            // Create assistant message from the response
            let assistantMessage = Message(
                role: .assistant,
                content: response.assistantResponse,
                id: UUID().uuidString,
                createdAt: Date()
            )
            
            // Check if the chat is still active before updating UI
            if isChatActive {
                // Update UI on main thread
                await MainActor.run {
                    self.messages.append(assistantMessage)
                    self.isAssistantResponding = false
                }
            } else {
                print("Chat is no longer active, discarding response")
                await MainActor.run {
                    self.isAssistantResponding = false
                }
            }
            
        } catch is CancellationError {
            print("Task was cancelled before completing")
            await MainActor.run {
                self.isAssistantResponding = false
            }
        } catch {
            if !Task.isCancelled {
                await MainActor.run {
                    print(error.localizedDescription)
                    self.isAssistantResponding = false
                }
            }
        }
    }
}
