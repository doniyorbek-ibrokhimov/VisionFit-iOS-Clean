//
//  SizePreferenceKey.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/04/25.
//


import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    private func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    func readSize(_ size: Binding<CGSize?>) -> some View {
        readSize { newSize in
            size.wrappedValue = newSize
        }
    }
}
