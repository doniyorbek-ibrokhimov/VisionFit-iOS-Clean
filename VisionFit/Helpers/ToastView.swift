//
//  ToastView.swift
//  Edu Plus Admin
//
//  Created by nigga on 02/04/25.
//

import SwiftUI

struct ToastView: View {
    var message: String
    var type: ToastType
    var onCancelTapped: (() -> Void)
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Button {
                onCancelTapped()
            } label: {
                type.icon
            }
            
            Text(LocalizedStringKey(message))
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
            
            Spacer(minLength: .zero)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(type.background)
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

enum ToastType {
    case error
    case warning
    case success
    
    var icon: Image {
        switch self {
        case .error: Image(systemName: "xmark.circle")
        case .warning: Image(systemName: "exclamationmark.triangle")
        case .success: Image(systemName: "checkmark.circle")
        }
    }
    
    var background: Color {
        switch self {
        case .error: Color(hex: "#F26262")
        case .warning: Color(hex: "#DBDB17")
        case .success: Color(hex: "#19CE63")
        }
    }
}

struct ToastModifier: ViewModifier {
    @Binding var message: String?
    @State private var workItem: DispatchWorkItem?
    var type: ToastType
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                }.animation(.bouncy, value: message)
            )
            .onChange(of: message) { _, _ in
                showToast()
            }
    }
    
    @ViewBuilder func mainToastView() -> some View {
        if let message {
            VStack {
                ToastView(
                    message: message,
                    type: type
                ) {
                    dismissToast()
                }
                Spacer()
            }
        }
    }
    
    private func showToast() {
        // UIImpactFeedbackGenerator(style: .heavy)
        //     .impactOccurred()
        
        workItem?.cancel()
        
        let task = DispatchWorkItem {
            dismissToast()
        }
        
        workItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: task)
    }
    
    private func dismissToast() {
        withAnimation {
            message = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}

extension View {
    func toast(message: Binding<String?>, type: ToastType) -> some View {
        self.modifier(ToastModifier(message: message, type: type))
    }
}
