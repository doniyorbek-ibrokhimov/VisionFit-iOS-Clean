//
//  ChatService.swift
//  Edu Plus Admin
//
//  Created by Doniyorbek Ibrokhimov on 08/04/25.
//

import Foundation
import HTTPClient

final class ChatService {
    func getSession(for userId: String) async throws -> [ChatSession] {
        let params: [String: Any] = ["user_id": userId]
        let response = try await AlamofireClient().task(
            URLs.sessionsURL,
            method: .get,
            parameters: params,
            encoding: .url,
            headers: [:]
        )

        let result: [ChatSessionDTO] = try ValidationWrapper.validate(response: response)
        return result.map { $0.uiModel }
    }

    func ask(question: String) async throws -> String {
        let params: [String: Any] = ["question": question]
        let response = try await AlamofireClient().task(
            URLs.askURL,
            method: .get,
            parameters: params,
            encoding: .url,
            headers: [:]
        )

        struct ChatResponse: Codable {
            let message: String
        }

        let result: ChatResponse = try ValidationWrapper.validate(response: response)
        return result.message
    }

    func chat(sessionId: String, message: String, imgUrl: String?) async throws
        -> ChatMessageResponse
    {
        let params: [String: Any] = [
            "session_id": sessionId,
            "message": message,
            "img_url": imgUrl,
        ]

        let response = try await AlamofireClient().task(
            URLs.chatURL,
            method: .post,
            parameters: params,
            encoding: .json,
            headers: [:]
        )

        let result: ChatMessageResponse = try ValidationWrapper.validate(response: response)
        return result
    }

    func createSession(title: String, userId: String) async throws -> ChatSession {
        let params: [String: Any] = [
            "title": title,
            "user_id": userId,
        ]

        let response = try await AlamofireClient().task(
            URLs.sessionsURL,
            method: .post,
            parameters: params,
            encoding: .json,
            headers: [:]
        )

        let result: ChatSessionDTO = try ValidationWrapper.validate(response: response)
        return result.uiModel
    }
}

fileprivate enum URLs {
    static var sessionsURL: URL {
        Constants.chatURL.appending(path: "sessions")
    }

    static var askURL: URL {
        Constants.chatURL.appending(path: "ask")
    }

    static var chatURL: URL {
        Constants.chatURL.appending(path: "chat")
    }
}
