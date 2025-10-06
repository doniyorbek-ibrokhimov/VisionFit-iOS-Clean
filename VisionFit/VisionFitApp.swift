//
//  VisionFitApp.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/12/24.
//

import SwiftUI

@main
struct VisionFitApp: App {

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                    .preferredColorScheme(.light)
            }
        }
    }
}
