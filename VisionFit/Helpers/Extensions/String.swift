//
//  String.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/04/25.
//

import Foundation

extension String {
    func stripMarkdown() -> String {
            var text = self
            
            // Remove bold, italic, code
            text = text.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
            text = text.replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
            text = text.replacingOccurrences(of: "_(.*?)_", with: "$1", options: .regularExpression)
            text = text.replacingOccurrences(of: "`(.*?)`", with: "$1", options: .regularExpression)
            
            // Remove markdown links: [text](url) → text
            text = text.replacingOccurrences(of: "\\[(.*?)\\]\\(.*?\\)", with: "$1", options: .regularExpression)
            
            // Remove heading markers
            text = text.replacingOccurrences(of: "^(#{1,6})\\s*", with: "", options: [.regularExpression, .anchored])
            
            // Remove list markers
            text = text.replacingOccurrences(of: "^[-*+]\\s*", with: "", options: [.regularExpression, .anchored])
            
            // Remove all remaining #
            text = text.replacingOccurrences(of: "#+", with: "", options: .regularExpression)
            
            // Replace newlines with space
            text = text.replacingOccurrences(of: "\n", with: " ")
            
            // Remove excess whitespace
            text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }

}
