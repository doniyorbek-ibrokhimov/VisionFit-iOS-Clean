# Environment Setup for VisionFit iOS

This document explains how to set up environment variables for the VisionFit iOS project to keep sensitive tokens secure.

## Required Environment Variables

The following environment variables must be set for the app to function properly:

### API Tokens
- `TEST_LIVEKIT_TOKEN` - Test LiveKit JWT token
- `LIVEKIT_TOKEN` - Production LiveKit JWT token  
- `ELEVEN_LABS_TOKEN` - ElevenLabs API key for voice synthesis
- `QUICKPOSE_SDK_KEY` - QuickPose SDK key for pose detection
- `GEMINI_API_KEY` - Google Gemini API key for AI conversations

### Optional Configuration
- `CHAT_URL` - Chat service URL (optional, falls back to default URLs)
- `WS_URL` - WebSocket URL (optional, falls back to default)

## Setting Up Environment Variables in Xcode

### Method 1: Scheme Environment Variables (Recommended)

1. Open your project in Xcode
2. Click on your project scheme at the top (next to the stop button)
3. Select "Edit Scheme..."
4. Go to the "Run" section in the left sidebar
5. Click on the "Arguments" tab
6. In the "Environment Variables" section, click the "+" button to add each variable:

```
TEST_LIVEKIT_TOKEN = your_test_livekit_token_here
LIVEKIT_TOKEN = your_production_livekit_token_here
ELEVEN_LABS_TOKEN = your_eleven_labs_token_here
QUICKPOSE_SDK_KEY = your_quickpose_sdk_key_here
GEMINI_API_KEY = your_gemini_api_key_here
CHAT_URL = your_chat_url_here (optional)
WS_URL = your_websocket_url_here (optional)
```

7. Check the checkbox next to each environment variable to enable it
8. Click "Close" to save your changes

### Method 2: Using .xcconfig Files

1. Create a new Configuration Settings File in Xcode:
   - Right-click your project → New File → Configuration Settings File
   - Name it `Secrets.xcconfig`

2. Add your environment variables to the file:
```
TEST_LIVEKIT_TOKEN = your_test_livekit_token_here
LIVEKIT_TOKEN = your_production_livekit_token_here
ELEVEN_LABS_TOKEN = your_eleven_labs_token_here
QUICKPOSE_SDK_KEY = your_quickpose_sdk_key_here
GEMINI_API_KEY = your_gemini_api_key_here
CHAT_URL = your_chat_url_here
WS_URL = your_websocket_url_here
```

3. Set the configuration file in your project settings:
   - Select your project in the navigator
   - Go to "Info" tab
   - Set the `Secrets` configuration for Debug and Release

## Security Notes

- **Never commit actual token values to version control**
- Add `Secrets.xcconfig` to your `.gitignore` file if using Method 2
- The app will crash with a descriptive error if required environment variables are missing
- This is intentional to prevent running with missing credentials

## Testing Your Setup

1. Build and run the app
2. If environment variables are missing, you'll see a clear error message
3. Check that all features requiring API access work correctly

## For Portfolio/Demo Purposes

If you're sharing this project as a portfolio:
1. Create example environment files with placeholder values
2. Document which services need API keys
3. Provide setup instructions for each required service

## Getting API Keys

- **LiveKit**: Sign up at [LiveKit Cloud](https://livekit.io/)
- **ElevenLabs**: Get API key from [ElevenLabs](https://elevenlabs.io/)
- **QuickPose**: Register at [QuickPose](https://quickpose.ai/)
- **Google Gemini**: Get API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

## Troubleshooting

- If the app crashes on launch, check that all required environment variables are set
- Verify that token formats match what the APIs expect
- Ensure URLs include proper protocols (https://, wss://)
