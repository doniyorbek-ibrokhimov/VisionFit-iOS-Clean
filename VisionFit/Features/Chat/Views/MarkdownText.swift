//
//  MarkdownText.swift
//  Edu Plus Admin
//
//  Created by Doniyorbek Ibrokhimov on 08/04/25.
//

import SwiftUI
import MarkdownUI

struct MarkdownText: View {
    let content: String

    init(_ content: String) {
        self.content = content
    }
    
    var body: some View {
        Markdown(.init(content))
    }
}
