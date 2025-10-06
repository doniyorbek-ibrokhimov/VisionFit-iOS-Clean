# VisionFit

An AI-powered fitness application that provides real-time exercise tracking, form analysis, and personalized coaching using computer vision and voice interaction.

## 🌟 Features

### 🤖 AI-Powered Fitness Coach
- **Real-time Voice Coaching**: Interactive AI trainer that provides live feedback during workouts
- **Form Analysis**: Advanced pose detection to analyze exercise form and provide corrections
- **Personalized Feedback**: Tailored coaching based on your performance and progress

### 📱 Exercise Tracking
- **18+ Exercise Types**: Comprehensive library including squats, push-ups, bicep curls, lunges, and more
- **Real-time Rep Counting**: Automatic repetition counting using computer vision
- **Progress Monitoring**: Track your workout metrics and improvements over time
- **Visual Feedback**: Live pose overlay with form guidance

### 💬 Interactive Chat
- **Voice & Text Chat**: Communicate with your AI trainer through voice or text
- **Exercise Guidance**: Get detailed instructions and tips for proper form
- **Progress Discussion**: Review your workout performance and get improvement suggestions

### 📊 Analytics Dashboard
- **Metrics Tracking**: Monitor weight, height, calories, and BMI trends
- **Interactive Charts**: Visual representation of your fitness journey
- **Performance Analytics**: Detailed insights into your workout patterns

## 🛠 Technologies Used

### Core Technologies
- **SwiftUI**: Modern iOS UI framework
- **Swift 5.9+**: Latest Swift language features
- **iOS 17+**: Targeting latest iOS capabilities

### AI & Machine Learning
- **Google MLKit**: Pose detection and analysis
- **QuickPose SDK**: Advanced fitness pose recognition
- **Custom AI Models**: Personalized coaching algorithms

### Networking & Communication
- **Alamofire**: HTTP networking
- **WebSocket**: Real-time communication
- **LiveKit**: Voice streaming infrastructure
- **ElevenLabs**: Text-to-speech capabilities

### Additional Libraries
- **CocoaPods**: Dependency management
- **Speech Recognition**: Voice input processing
- **AVFoundation**: Camera and audio handling

## 📋 Requirements

- **iOS**: 15.0+
- **Xcode**: 14.0+
- **Swift**: 5.9+
- **Device**: iPhone with camera and microphone
- **Permissions**: Camera, microphone, and speech recognition access

## 🚀 Installation

### Prerequisites
1. Install [CocoaPods](https://cocoapods.org/)
```bash
sudo gem install cocoapods
```

### Setup
1. Clone the repository
```bash
git clone https://github.com/your-username/VisionFit.git
cd VisionFit
```

2. Install dependencies
```bash
pod install
```

3. Open the workspace
```bash
open VisionFit.xcworkspace
```

4. Configure Environment Variables
   - See [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) for detailed instructions
   - Set up required API keys as environment variables in Xcode
   - Never commit actual API keys to version control

5. Build and run the project

## 🏗 Project Structure

```
VisionFit/
├── VisionFit/
│   ├── Features/
│   │   ├── Home/                 # Main dashboard and metrics
│   │   ├── Camera/               # Exercise tracking and pose detection
│   │   ├── Chat/                 # AI chat interface
│   │   ├── VoiceStream/          # Voice communication
│   │   ├── Profile/              # User profile management
│   │   └── Login/                # Authentication
│   ├── Helpers/                  # Utilities and constants
│   ├── Extensions/               # Swift extensions
│   └── Resources/                # Assets and resources
├── HTTPClient/                   # Custom networking package
├── AI Playground/                # AI model experiments
└── Pods/                         # CocoaPods dependencies
```

## 🎯 Usage

### Starting a Workout
1. Launch the app and select an exercise from the home screen
2. Position yourself in front of the camera within the bounding box
3. Follow the AI trainer's voice instructions
4. Receive real-time feedback on your form and rep counting

### Chat with AI Trainer
1. Tap the chat bar at the bottom of the home screen
2. Ask questions about exercises, form, or fitness goals
3. Use voice or text input for natural conversation

### Tracking Progress
1. View your metrics on the home dashboard
2. Switch between different metric types (weight, height, calories, BMI)
3. Monitor your improvement trends over time

## 🔧 Configuration

### Environment Variables Setup
This project uses environment variables to keep sensitive API keys secure. 

**Required Environment Variables:**
- `TEST_LIVEKIT_TOKEN` - Test LiveKit JWT token
- `LIVEKIT_TOKEN` - Production LiveKit JWT token  
- `ELEVEN_LABS_TOKEN` - ElevenLabs API key
- `QUICKPOSE_SDK_KEY` - QuickPose SDK key
- `GEMINI_API_KEY` - Google Gemini API key

**Optional Configuration:**
- `CHAT_URL` - Custom chat service URL
- `WS_URL` - Custom WebSocket URL

For detailed setup instructions, see [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md).

### Environment Configuration
The app supports different environments:
- **Debug**: Development environment with test URLs
- **Release**: Production environment

## 🧪 Testing

### Build and Test
```bash
# Build the project
xcodebuild -scheme VisionFit -configuration Debug -workspace VisionFit.xcworkspace build

# Run on simulator
xcodebuild -scheme VisionFit -configuration Debug -workspace VisionFit.xcworkspace -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## 📱 Supported Exercises

- **Upper Body**: Push-ups, Bicep Curls, Lateral Raises, Front Raises, Overhead Press
- **Lower Body**: Squats, Sumo Squats, Lunges, Side Lunges, Hip Abduction
- **Core**: Sit-ups, Plank, V-ups, Leg Raises, Glute Bridge
- **Cardio**: Jumping Jacks, Cobra Wings

## 🔐 Privacy & Permissions

The app requires the following permissions:
- **Camera**: For exercise tracking and pose detection
- **Microphone**: For voice interaction with AI trainer
- **Speech Recognition**: For voice command processing

### Security Features
- **Environment Variables**: All sensitive API keys are stored as environment variables
- **Local Processing**: Data processing is done locally on device where possible
- **No Hardcoded Secrets**: No API keys or tokens are committed to version control

All data processing is done locally on device where possible, ensuring user privacy.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the project's `.windsurfrules` for iOS development standards
- Use SwiftUI and modern Swift features
- Implement proper error handling
- Add comprehensive documentation
- Test thoroughly on real devices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Google MLKit** for pose detection capabilities
- **QuickPose** for advanced fitness pose recognition
- **ElevenLabs** for natural voice synthesis
- **LiveKit** for real-time communication infrastructure

## 📧 Support

For support and questions:
- Create an issue in this repository
- Contact the development team
- Check the documentation in the `/docs` folder

---

**VisionFit** - Your AI-powered fitness companion for better workouts and healthier living! 💪