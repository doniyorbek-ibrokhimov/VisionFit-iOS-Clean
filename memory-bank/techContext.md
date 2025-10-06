# VisionFit Technical Context

## Technology Stack

### Core iOS Development
- **Language**: Swift 5.0+
- **Framework**: SwiftUI (iOS 15.0+)
- **Architecture**: MVVM with Combine
- **Platform**: iOS 15.0 minimum deployment target

### Computer Vision & ML
- **Primary ML Framework**: Google MLKit
  - `GoogleMLKit/PoseDetection` - Standard pose detection
  - `GoogleMLKit/PoseDetectionAccurate` - High-accuracy pose detection
- **Camera Integration**: AVFoundation
- **Real-time Processing**: Core Video pipeline

### Voice & Communication
- **Voice Streaming**: Pipecat Client iOS
- **WebSocket Communication**: Gemini Live WebSocket integration
- **Audio Processing**: Custom voice streaming implementation

### Development Tools
- **IDE**: Xcode 15.0+
- **Package Management**: CocoaPods + Swift Package Manager
- **Version Control**: Git with submodules
- **Code Formatting**: `.swift-format` configuration

## Project Structure

### Main Application
```
VisionFit/
├── VisionFitApp.swift (Entry point)
├── Features/ (Feature modules)
├── Helpers/ (Utilities and extensions)
└── Resources/ (Assets and configurations)
```

### External Dependencies
```
pipecat-client-ios/ (Voice streaming)
pipecat-client-ios-gemini-live-websocket/ (WebSocket voice)
HTTPClient/ (Network utilities)
AI Playground/ (Development experiments)
```

## Dependency Management

### CocoaPods Dependencies
```ruby
platform :ios, '15.0'
pod 'GoogleMLKit/PoseDetection'
pod 'GoogleMLKit/PoseDetectionAccurate'
```

### Swift Package Dependencies
- Pipecat Client iOS (Local package)
- HTTP Client utilities (Local package)

## Technical Constraints

### Performance Requirements
- **Real-time Processing**: <1 second latency for pose detection
- **Frame Rate**: 30 FPS camera processing
- **Memory Management**: Optimized for continuous video processing
- **Battery Efficiency**: Minimal background processing

### Platform Limitations
- **Camera Access**: Requires user permission
- **Network Dependency**: Voice features require internet connection
- **Storage**: Minimal local data storage (user preferences only)
- **Processing Power**: Must work on iPhone 12 and newer

### MLKit Constraints
- **Offline Processing**: Pose detection works without internet
- **Accuracy Trade-offs**: Standard vs. accurate detection models
- **Device Compatibility**: iOS 15.0+ requirement
- **Model Size**: Embedded ML models impact app size

## Development Environment

### Required Tools
- macOS 13.0+ (for Xcode 15.0+)
- Xcode 15.0 or later
- CocoaPods 1.11+
- Git with LFS support

### API Keys & Configuration
- QuickPose SDK key (stored in Constants)
- Google MLKit (no key required)
- Pipecat service configuration

### Build Configuration
- Debug: Full logging and development features
- Release: Optimized performance, minimal logging
- TestFlight: Beta testing configuration

## Testing Strategy

### Unit Testing
- Exercise logic validation
- Pose detection accuracy
- Voice integration reliability

### Integration Testing
- Camera session management
- MLKit pose detection pipeline
- Voice streaming connectivity

### Performance Testing
- Frame rate consistency
- Memory usage monitoring
- Battery consumption analysis

## Deployment

### App Store Requirements
- iOS 15.0+ minimum version
- Camera usage description
- Microphone usage description (for voice features)
- Privacy policy for ML processing

### Distribution
- TestFlight for beta testing
- App Store distribution for public release
- Enterprise distribution (if applicable)

## Security Considerations
- **Local Processing**: Pose detection happens on-device
- **Data Privacy**: No video data stored or transmitted
- **Voice Data**: Encrypted transmission for voice features
- **Permissions**: Explicit user consent for camera/microphone access 