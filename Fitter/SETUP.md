# Fitter Setup Guide

Welcome to Fitter! This guide will help you set up the project for development.

## Prerequisites

- iOS 18.5+
- Xcode 16.0+
- Swift 5.0+

## API Keys Required

Before building the project, you'll need to obtain and configure the following API keys:

### 1. OpenAI API Key (Required for AI Assistant)

1. Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. Create an account or sign in
3. Generate a new API key
4. Copy the key (starts with `sk-`)

### 2. USDA Food Data Central API Key (Food Tracking)

**Good news!** The project comes pre-configured with `DEMO_KEY` which works immediately for testing and development.

For production use or higher rate limits:
1. Visit [USDA FoodData Central](https://fdc.nal.usda.gov/api-key-signup.html)
2. Sign up for a free API key
3. Replace `DEMO_KEY` with your personal API key in `APIConfig.swift`

## Configuration

1. **Update API Keys**
   - Open `Fitter/Config/APIConfig.swift`
   - Replace `"your_openai_api_key_here"` with your OpenAI API key
   - Replace `"your_usda_api_key_here"` with your USDA API key

2. **Update Bundle Identifier** (Optional)
   - Open the Xcode project
   - Select the Fitter target
   - Go to "Signing & Capabilities"
   - Update the Bundle Identifier to your own (e.g., `com.yourcompany.Fitter`)
   - Also update the `appGroupID` in `DataManager.swift` to match your bundle identifier

3. **App Group Configuration** (If you changed bundle identifier)
   - In `Services/DataManager.swift`, update:
   ```swift
   private let appGroupID = "group.com.yourcompany.Fitter"
   ```

## Building the Project

1. Clone the repository
2. Open `Fitter.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (⌘+R)

## Features Overview

- **Fasting Tracking**: Start, monitor, and log intermittent fasting sessions
- **Food Logging**: Camera-based food recognition and calorie tracking
- **Exercise Tracking**: Log workouts and sync with Apple Health
- **Analytics**: View progress charts and health insights
- **Gamification**: Earn XP, unlock achievements, and complete challenges
- **AI Assistant**: Get personalized health recommendations
- **Health Calculators**: BMI, macro calculators, and more

## Contributing

We welcome contributions! Please feel free to submit issues and pull requests.

## License

This project is open source. See LICENSE file for details.

## Support

If you encounter any issues during setup, please open an issue on GitHub.
