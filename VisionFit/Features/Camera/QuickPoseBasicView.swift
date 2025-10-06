//
//  QuickPose_BasicDemoApp.swift
//  QuickPose Demo
//
//  Created by QuickPose.ai on 12/12/2022.
//

import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI

struct QuickPoseBasicView: View {
    let features: [QuickPose.Feature]
    
    init(features: [QuickPose.Feature]) {
        self.features = features
    }
    
    private var quickPose = QuickPose(sdkKey: Constants.quickPoseSDKKey) // register for your free key at https://dev.quickpose.ai
    @State private var overlayImage: UIImage?
    @State private var feedbackText: String? = nil
    @State private var counter = QuickPoseThresholdCounter()
    @EnvironmentObject private var viewModel: ExerciseTrackerViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                QuickPoseCameraView(useFrontCamera: viewModel.isUsingFrontCamera, delegate: quickPose)
                QuickPoseOverlayView(overlayImage: $overlayImage)
            }
            .overlay(alignment: .center) {
                if let feedbackText = feedbackText {
                    Text(feedbackText)
                        .font(.system(size: 26, weight: .semibold)).foregroundColor(.white).multilineTextAlignment(.center)
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color("AccentColor").opacity(0.8)))
                        .padding(.bottom, 40)
                }
            }
            .onAppear {
                quickPose.start(features: features, onFrame: { status, image, features, feedback, landmarks in
                    overlayImage = image
                    switch status {
                    case .success:
                        if let result = features.values.first  {
                            let counterState = counter.count(result.value)
                            feedbackText = "\(counterState.count) Front Raises"
                        } else if let feedback = feedback.values.first, feedback.isRequired  {
                            feedbackText = feedback.displayString
                        } else {
                            feedbackText = nil
                        }
                    case .noPersonFound:
                        feedbackText = "Stand in view";
                    case .sdkValidationError:
                        feedbackText = "Be back soon";
                    }
                })
            }.onDisappear {
                quickPose.stop()
            }
            .frame(width: geometry.size.width)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

