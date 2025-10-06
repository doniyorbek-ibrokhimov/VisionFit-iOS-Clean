//
//  MessageDTO.swift
//  Edu Plus Admin
//
//  Created by Doniyorbek Ibrokhimov on 08/04/25.
//

import Foundation

struct MessageDTO: Codable {
    var role: String
    var content: String
    var id: String
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
        case id
        case createdAt = "created_at"
    }
    
    var uiModel: Message {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let createdAtDate = dateFormatter.date(from: createdAt) ?? Date()
        
        return Message(
            role: MessageRole(rawValue: role) ?? .user,
            content: content,
            id: id,
            createdAt: createdAtDate
        )
    }
}
