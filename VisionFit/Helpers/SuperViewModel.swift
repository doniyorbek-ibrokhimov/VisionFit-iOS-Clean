//
//  SuperViewModel.swift
//  Symptom Checker
//
//  Created by nigga on 14/11/24.
//

import Foundation

@MainActor
class SuperViewModel: ObservableObject {
    @Published var state: ViewState = .initial
    
    func onLoad() async { }
    
    func onDisappear() { }
    
    enum ViewState: Equatable {
        case initial
        case loading
        case loaded
        case error(String)
        case empty
    }
}
