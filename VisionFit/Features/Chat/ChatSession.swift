//
//  ChatSession.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/04/25.
//


import Foundation

struct ChatSession {
    var title: String
    var id: String
    var userId: String
    var createdAt: Date
    var updatedAt: Date
    var messages: [Message]
}
