//
//  Constants.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/04/25.
//

import SwiftUI

enum Constants {
    static let circleViewAlpha: CGFloat = 0.7
    static let rectangleViewAlpha: CGFloat = 0.3
    static let shapeViewAlpha: CGFloat = 0.3
    static let rectangleViewCornerRadius: CGFloat = 10.0
    static let maxColorComponentValue: CGFloat = 255.0
    static let originalScale: CGFloat = 1.0
    static let bgraBytesPerPixel = 4
    static let circleViewIdentifier = "MLKit Circle View"
    static let lineViewIdentifier = "MLKit Line View"
    static let rectangleViewIdentifier = "MLKit Rectangle View"

    static let voiceAI = "VisionAI"
    static var testLiveKitToken: String {
        guard let token = ProcessInfo.processInfo.environment["TEST_LIVEKIT_TOKEN"] else {
            fatalError("TEST_LIVEKIT_TOKEN environment variable not set")
        }
        return token
    }

    //TODO: update urls
    static var baseURL: URL {
        #if DEBUG
            if AppCore.shared.isDebugModeEnabled {
                URL(string: "https://test-lms.eduplus.uz/")!
            }
            else {
                URL(string: "https://lms.eduplus.uz/")!
            }
        #else
            URL(string: "https://lms.eduplus.uz/")!
        #endif
    }

    static var chatURL: URL {
        if let urlString = ProcessInfo.processInfo.environment["CHAT_URL"] {
            return URL(string: urlString)!
        }
        
        #if DEBUG
            if AppCore.shared.isDebugModeEnabled {
                return URL(string: "https://2ce2-84-54-115-235.ngrok-free.app/api/v1/")!
            }
            else {
                return URL(string: "https://2ce2-84-54-115-235.ngrok-free.app/api/v1")!
            }
        #else
            return URL(string: "https://2ce2-84-54-115-235.ngrok-free.app/api/v1")!
        #endif
    }

    static var elevenLabsToken: String {
        guard let token = ProcessInfo.processInfo.environment["ELEVEN_LABS_TOKEN"] else {
            fatalError("ELEVEN_LABS_TOKEN environment variable not set")
        }
        return token
    }
    static var wsURL: String {
        if let url = ProcessInfo.processInfo.environment["WS_URL"] {
            return url
        }
        return "wss://visionfit-3ngwgg9f.livekit.cloud"
    }
    
    static var token: String {
        guard let token = ProcessInfo.processInfo.environment["LIVEKIT_TOKEN"] else {
            fatalError("LIVEKIT_TOKEN environment variable not set")
        }
        return token
    }

    static var quickPoseSDKKey: String {
        guard let key = ProcessInfo.processInfo.environment["QUICKPOSE_SDK_KEY"] else {
            fatalError("QUICKPOSE_SDK_KEY environment variable not set")
        }
        return key
    }

    static let systemInstruction = """
        You are VisionFit, an AI fitness trainer. Be concise in all responses.
        
        Key information:
        - You receive user's real-time exercise data in text form (exercise name, repetition counts, total reps, current round)
        - Analyze this data intelligently, DO NOT just repeat it back to the user
        - Users will receive specific form feedback directly from the app
        - You can see the user's video stream and should reference what you observe in your feedback
        
        Exercise descriptions below provide essential form cues and common mistakes for each exercise. Use this knowledge to:
        1. Provide targeted encouragement based on exercise progress
        2. Recognize when users might be struggling with proper form
        3. Offer appropriate difficulty modifications when needed
        
        Your role:
        - Be a motivating coach who understands exercise biomechanics
        - Give specific, actionable feedback based on exercise progress
        - Address form issues when you observe them or when specifically mentioned
        - Keep instructions brief (1 short sentence) as users primarily receive audio feedback
        - Tailor encouragement based on rep counts and exercise difficulty level
        
        Communication style:
        - Clear, direct instructions using coaching language
        - Enthusiastic but professional tone
        - Focus on key form cues and immediate actionable guidance
        - Use varied encouragement phrases to maintain motivation
        
        Avoid:
        - Medical advice or injury diagnoses
        - Lengthy explanations during active exercises
        - Repeating the same feedback patterns repeatedly
        - Talking too much
        - USING THE WORD REPRESENTATIVE, REP IS SHORT FOR REPETITION NOT FOR REPRESENTATIVE
        """
    
    /*
     Exercise descriptions:
     - Squat: \(ExerciseType.squat.description)
     - Push Ups: \(ExerciseType.pushUps.description)
     - Jumping Jacks: \(ExerciseType.jumpingJacks.description)
     - Sumo Squats: \(ExerciseType.sumoSquats.description)
     - Lunges: \(ExerciseType.lunges.description)
     - Sit Ups: \(ExerciseType.sitUps.description)
     - Cobra Wings: \(ExerciseType.cobraWings.description)
     - Plank: \(ExerciseType.plank.description)
     - Plank Straight Arm: \(ExerciseType.plankStraightArm.description)
     - Leg Raises: \(ExerciseType.legRaises.description)
     - Glute Bridge: \(ExerciseType.gluteBridge.description)
     - Overhead Dumbbell Press: \(ExerciseType.overheadDumbbellPress.description)
     - V Ups: \(ExerciseType.vUps.description)
     - Lateral Raises: \(ExerciseType.lateralRaises.description)
     - Front Raises: \(ExerciseType.frontRaises.description)
     - Hip Abduction Standing: \(ExerciseType.hipAbductionStanding.description)
     - Side Lunges: \(ExerciseType.sideLunges.description)
     - Arm Raises: \(ExerciseType.bicepCurls.description)
     - Single Arm Bicep Curls: \(ExerciseType.bicepCurlsSingleArm.description)
     */
}
