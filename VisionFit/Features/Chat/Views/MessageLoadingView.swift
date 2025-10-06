//
//  MessageLoadingView.swift
//  Edu Plus Admin
//
//  Created by nigga on 16/04/25.
//

import SwiftUI

struct MessageLoadingView: View {
    @State var state: LoadingState = .thinking
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                switch state {
                case .thinking:
                    Image(systemName: "person")
                    Text("chat-thinking")
                case .syncing:
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    Text("chat-syncing")
                case .aLittleMoreTime:
                    Image(systemName: "person")
                    Text("chat-a-little-more")
                case .finishing:
                    Image(systemName: "person")
                    Text("chat-finishing")
                }
            }
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(Color.blue.gradient)
            .transition(.opacity)
            
            Spacer()
        }
        .onReceive(timer) { _ in
            withAnimation {
                state.next()
            }
        }
        .onAppear {
            state = .thinking
        }
        .onDisappear {
            state = .thinking
        }
    }
    
    enum LoadingState {
        case thinking
        case syncing
        case aLittleMoreTime
        case finishing
        
        mutating func next() {
            switch self {
            case .thinking:
                self = .syncing
            case .syncing:
                self = .aLittleMoreTime
            case .aLittleMoreTime:
                self = .finishing
            case .finishing:
                break
            }
        }
    }
}
