# VisionFit System Patterns

## Architecture Overview
VisionFit follows a modular SwiftUI architecture with clear separation of concerns:

```
VisionFitApp (Entry Point)
├── Features/
│   ├── Home/ (Dashboard & Navigation)
│   ├── Camera/ (Exercise Tracking)
│   ├── Chat/ (AI Voice Assistant)
│   ├── Profile/ (User Management)
│   └── VoiceStream/ (Voice Communication)
├── Helpers/ (Utilities & Extensions)
└── Resources/ (Assets & Configuration)
```

## Key Design Patterns

### MVVM Architecture
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: ObservableObject classes handling business logic
- **Models**: Data structures and types (ExerciseType, Metric, etc.)

Example: `ExerciseTrackerView` + `ExerciseTrackerViewModel`

### Coordinator Pattern
- Navigation managed through `@State` and `NavigationStack`
- Destination-based navigation with matched geometry effects
- Deep linking support for specific exercise types

### Publisher-Subscriber Pattern
- `@StateObject` and `@ObservedObject` for reactive updates
- Real-time camera data flow to UI components
- Voice assistant status updates

### Dependency Injection
- ViewModels injected as `@StateObject`
- Shared instances passed via `@EnvironmentObject`
- Service layer abstraction for external dependencies

## Component Relationships

### Core Flow
1. **HomeView** → Exercise selection and metrics dashboard
2. **ExerciseTrackerView** → Camera + pose detection + voice coaching
3. **CameraPreview** → AVFoundation session wrapper
4. **Voice Integration** → Pipecat client for AI communication

### Data Flow
```
Camera Session → MLKit Pose Detection → Exercise Logic → UI Updates
                                     ↓
Voice Assistant ← Exercise Events ← Counter/Feedback System
```

## State Management Patterns

### Exercise Tracking State
- Real-time rep counting (`leftHandCount`, `rightHandCount`)
- Form feedback (`isSameLine`, `armRaisesFeedback`)
- Session management (`isFinished`, exercise type)

### Navigation State
- `@State` for local navigation decisions
- `@Namespace` for matched geometry effects
- Environment-based data sharing

### Voice Assistant State
- Connection status tracking (`voiceClientStatus`)
- Message queuing for exercise data
- Feedback throttling (3-second intervals)

## MLKit Integration Pattern
- Pose detection pipeline with real-time processing
- Landmark extraction and analysis
- Exercise-specific logic (bicep curls, push-ups, squats)
- Performance optimization for mobile processing

## Voice Integration Pattern
- Pipecat client for WebSocket communication
- Exercise event streaming to AI coach
- Real-time feedback delivery
- Connection management and reconnection logic

## UI Pattern Standards
- **Color Scheme**: Primary green/dark with light backgrounds
- **Animations**: `withAnimation(.easeInOut)` for smooth transitions
- **Layout**: Frame-based sizing with screen-relative dimensions
- **Feedback**: Visual indicators combined with voice feedback

## Error Handling Patterns
- Graceful camera permission handling
- Network connectivity management for voice features
- MLKit processing error recovery
- User-friendly error messages

## Performance Patterns
- Camera session lifecycle management
- Real-time processing optimization
- Memory management for continuous video processing
- Background/foreground state handling 