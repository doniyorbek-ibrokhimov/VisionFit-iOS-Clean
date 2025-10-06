//
//  ChatSessionDTO.swift
//  Edu Plus Admin
//
//  Created by Doniyorbek Ibrokhimov on 08/04/25.
//

import Foundation

struct ChatSessionDTO: Codable {
    var title: String
    var id: String
    var userId: String
    var createdAt: String
    var updatedAt: String
    var messages: [MessageDTO]
    
    enum CodingKeys: String, CodingKey {
        case title
        case id
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case messages
    }
    
    var uiModel: ChatSession {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let createdAtDate = dateFormatter.date(from: createdAt) ?? Date()
        let updatedAtDate = dateFormatter.date(from: updatedAt) ?? Date()
        
        return ChatSession(
            title: title,
            id: id,
            userId: userId,
            createdAt: createdAtDate,
            updatedAt: updatedAtDate,
            messages: messages.map { $0.uiModel }
        )
    }
}
