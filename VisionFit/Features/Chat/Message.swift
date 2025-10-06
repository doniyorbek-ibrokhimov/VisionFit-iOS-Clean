//
//  Message.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/04/25.
//


import Foundation

struct Message: Identifiable, Hashable {
    let role: MessageRole
    let content: String
    let id: String
    let createdAt: Date
}