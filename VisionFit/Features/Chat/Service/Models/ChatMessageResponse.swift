//
//  ChatMessageResponse.swift
//  Edu Plus Admin
//
//  Created by Doniyorbek Ibrokhimov on 08/04/25.
//

import Foundation

struct ChatMessageResponse: Codable {
    let sessionId: String
    let message: String
    let assistantResponse: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case message
        case assistantResponse = "assistant_response"
        case status
    }
}
