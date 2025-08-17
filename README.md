# Fitter - Fitness & Fasting App

A comprehensive iOS app for tracking intermittent fasting and calorie intake, built with SwiftUI.

> **🎉 This project is now open source!** Feel free to contribute, fork, and build upon it.

## 🚀 Quick Start

1. **Clone the repository**
2. **Follow the [SETUP.md](SETUP.md) guide** to configure API keys
3. **Build and run** in Xcode

**⚠️ Important**: You'll need to add your own API keys before building. See [SETUP.md](SETUP.md) for details.

## Features

### 🏠 Home Dashboard
- **Fasting Status**: Real-time tracking of active fasting sessions with progress visualization
- **Calorie Progress**: Daily calorie intake tracking with macronutrient breakdown
- **Quick Actions**: Easy access to start fasting or log food

### ⏰ Fasting Tracking
- **Active Session Monitoring**: Live timer with progress circles and time remaining
- **Fasting Plans**: Customizable fasting windows based on goals (16:8, 14:10, 12:12, etc.)
- **Session Management**: Start, pause, and end fasting sessions
- **Goal-Based Plans**: Automatic plan generation based on user goals (Weight Loss, Maintenance, Muscle Gain, General Health)

### 🔥 Calorie Tracking
- **Food Logging**: Add food items with calories and macronutrients
- **Daily Summary**: Visual progress rings and detailed nutrition breakdown
- **Macronutrient Tracking**: Protein, carbs, and fat tracking
- **Smart Calculations**: Automatic calorie targets based on user profile

### 👤 Profile Management
- **User Profile**: Complete onboarding with age, gender, height, weight, activity level
- **Goal Setting**: Choose fasting goals and calorie targets
- **Profile Editing**: Update personal information and preferences
- **Target Calculations**: Automatic BMR and TDEE calculations using Mifflin-St Jeor equation

## Technical Implementation

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **UserDefaults**: Local data persistence
- **ObservableObject**: Reactive data management

### Key Components

#### Models
- `UserProfile`: Stores user demographics and preferences
- `FastingSession`: Tracks active fasting periods
- `FoodEntry`: Represents logged food items
- `DailyNutrition`: Aggregates daily nutrition data

#### Services
- `DataManager`: Singleton for data persistence and management
- `CalorieCalculator`: Scientific calculations using Mifflin-St Jeor equation

#### Views
- `OnboardingView`: Step-by-step user setup
- `MainTabView`: Tab navigation container
- `HomeView`: Dashboard with fasting and calorie status
- `FastingView`: Detailed fasting tracking and management
- `CaloriesView`: Food logging and nutrition tracking
- `ProfileView`: User profile and settings

### Calorie Calculation Algorithm

The app uses the **Mifflin-St Jeor Equation** for accurate calorie calculations:

**BMR Calculation:**
- Male: `(10 × weight) + (6.25 × height) - (5 × age) + 5`
- Female: `(10 × weight) + (6.25 × height) - (5 × age) - 161`

**Activity Multipliers:**
- Sedentary: 1.2
- Lightly Active: 1.375
- Moderately Active: 1.55
- Very Active: 1.725
- Extremely Active: 1.9

**Goal Adjustments:**
- Weight Loss: -500 calories
- Maintenance: No adjustment
- Muscle Gain: +300 calories
- General Health: -200 calories

### Fasting Plans

The app provides goal-based fasting plans:

- **Weight Loss**: 16:8 (16 hours fasting, 8 hours eating)
- **Maintenance**: 14:10 (14 hours fasting, 10 hours eating)
- **Muscle Gain**: 12:12 (12 hours fasting, 12 hours eating)
- **General Health**: 16:8 (16 hours fasting, 8 hours eating)

## Getting Started

1. **Clone the repository**
2. **Open in Xcode**
3. **Build and run on iOS Simulator or device**
4. **Complete onboarding** to set up your profile
5. **Start tracking** your fasting and nutrition!

## Requirements

- iOS 18.5+
- Xcode 16.0+
- Swift 5.0+

## Data Privacy

All data is stored locally on the device using UserDefaults. No data is transmitted to external servers.

## Future Enhancements

- [ ] Cloud sync with iCloud
- [ ] Apple Health integration
- [ ] Push notifications for fasting reminders
- [ ] Advanced analytics and charts
- [ ] Social features and sharing
- [ ] Barcode scanning for food items
- [ ] Meal planning and recipes

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Ways to Contribute
- 🐛 **Report bugs** by opening an issue
- 💡 **Suggest features** or improvements
- 🔧 **Submit pull requests** with bug fixes or new features
- 📖 **Improve documentation**
- 🎨 **Enhance UI/UX design**

### Development Guidelines
- Follow Swift coding conventions
- Write clear commit messages
- Add comments for complex logic
- Test your changes thoroughly
- Update documentation when needed

### Getting Started
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- Thanks to all contributors
- Built with love using SwiftUI
- Inspired by the health and fitness community 
