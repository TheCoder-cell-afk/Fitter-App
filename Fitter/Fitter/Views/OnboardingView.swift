import SwiftUI
import AVFoundation

struct OnboardingView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var name = ""
    @State private var age = ""
    @State private var gender: Gender = .male
    @State private var height = ""
    @State private var weight = ""
    @State private var activityLevel: ActivityLevel = .sedentary
    @State private var fastingGoal: FastingGoal = .weightLoss
    @State private var fitnessGoal: FitnessGoal = .fatLoss
    @State private var dailyCalorieTarget = ""
    @State private var gamificationEnabled = true
    @State private var showValidationError = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                }
                
                Section(header: Text("Physical Info")) {
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Activity & Goals")) {
                    Picker("Activity Level", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    Picker("Fasting Goal", selection: $fastingGoal) {
                        ForEach(FastingGoal.allCases, id: \.self) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                    Picker("Fitness Goal", selection: $fitnessGoal) {
                        ForEach(FitnessGoal.allCases, id: \.self) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                    TextField("Daily Calorie Target", text: $dailyCalorieTarget)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    Toggle("Enable Gamification Features", isOn: $gamificationEnabled)
                }
                
                Section {
                    Button("Complete Onboarding") {
                        completeOnboarding()
                    }
                    .disabled(!formIsValid)
                }
                
                if showValidationError {
                    Section {
                        Text("Please fill all required fields with valid values.")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Onboarding")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var formIsValid: Bool {
        !name.isEmpty &&
        Int(age) != nil &&
        Double(height) != nil &&
        Double(weight) != nil &&
        Int(dailyCalorieTarget) != nil
    }

    private func completeOnboarding() {
        guard formIsValid else {
            showValidationError = true
            return
        }
        showValidationError = false

        let profile = UserProfile(
            name: name,
            age: Int(age) ?? 0,
            gender: gender,
            height: Double(height) ?? 0,
            weight: Double(weight) ?? 0,
            activityLevel: activityLevel,
            fastingGoal: fastingGoal,
            fitnessGoal: fitnessGoal,
            dailyCalorieTarget: Int(dailyCalorieTarget) ?? 0,
            gamificationEnabled: gamificationEnabled
        )

        dataManager.saveUserProfile(profile)
        hasCompletedOnboarding = true
        notificationManager.requestNotificationPermission()
        requestCameraPermission()
        
        // Mark onboarding as complete in DataManager as well for backward compatibility
        dataManager.completeOnboarding()
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    print("Camera access granted")
                } else {
                    print("Camera access denied")
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthManager())
}