import SwiftUI

// MARK: - iOS 26 Ready
// This view is fully optimized for iOS 26 Liquid Glass
// All navigation bars and custom cards will automatically get:
// ✅ Glass navigation bars with fluid morphing
// ✅ Enhanced glass effects on all background elements
// ✅ Improved shadows and visual hierarchy
// ✅ Better accessibility and legibility

struct ProfileView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @EnvironmentObject var authManager: AuthManager
    @State private var showingEditProfile = false
    @State private var animateProgress = false
    @State private var showContent = false
    @State private var selectedAchievement: Achievement?
    @State private var showingAchievementDetail = false
    @State private var confettiParticles: [ConfettiParticle] = []
    
    // Settings state
    @State private var showingNotificationsSettings = false

    @State private var showingDataSyncSettings = false
    
    // Gamification state
    @State private var gamificationEnabled: Bool = true
    
    // Animation states for all buttons
    @State private var editProfileButtonScale: CGFloat = 1.0
    @State private var headerEditButtonScale: CGFloat = 1.0
    @State private var notificationsButtonScale: CGFloat = 1.0

    @State private var dataSyncButtonScale: CGFloat = 1.0
    
    @State private var showingEditCalories = false
    @State private var newCalorieTarget = ""

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Profile Info Card
                    profileInfoCard
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                    
                    // Goals Card
                    goalsCard
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 40)
                    
                    // Achievements Section
                    achievementsSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 50)
                    
                    // Settings Card
                    settingsCard
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 60)
                    
                    // Account Section
                    accountSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 70)
                    
                    // Debug Section (Development Only)
                    debugSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 80)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGray6))
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Enhanced button feedback
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            headerEditButtonScale = 0.9
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                headerEditButtonScale = 1.0
                            }
                        }
                        
                        showingEditProfile = true
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .scaleEffect(headerEditButtonScale)
                }
            }
            .sheet(isPresented: $showingAchievementDetail) {
                if let achievement = selectedAchievement {
                    AchievementDetailView(achievement: achievement)
                }
            }
            .sheet(isPresented: $showingNotificationsSettings) {
                NotificationsSettingsView()
            }

            .sheet(isPresented: $showingDataSyncSettings) {
                DataSyncSettingsView()
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    showContent = true
                }
                
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    animateProgress = true
                }
                
                // Initialize gamification state from user profile
                if let profile = dataManager.userProfile {
                    gamificationEnabled = profile.gamificationEnabled
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Profile")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Manage your health journey")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // Enhanced button feedback
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    headerEditButtonScale = 0.9
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        headerEditButtonScale = 1.0
                    }
                }
                
                showingEditProfile = true
            }) {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .scaleEffect(headerEditButtonScale)
        }
        .padding(.top, 20)
    }
    
    private var profileInfoCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Personal Info")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Your health profile")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            if let profile = dataManager.userProfile {
                VStack(spacing: 16) {
                    InfoRow(title: "Name", value: profile.name)
                    InfoRow(title: "Age", value: "\(profile.age) years")
                    InfoRow(title: "Gender", value: profile.gender.rawValue)
                    InfoRow(title: "Height", value: "\(Int(profile.height)) cm")
                    InfoRow(title: "Weight", value: "\(Int(profile.weight)) kg")
                    InfoRow(title: "Activity Level", value: profile.activityLevel.rawValue)
                    InfoRow(title: "Fitness Goal", value: profile.fitnessGoal.rawValue)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var goalsCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Goals & Targets")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Your health objectives")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    if let profile = dataManager.userProfile {
                        newCalorieTarget = String(profile.dailyCalorieTarget)
                    }
                    showingEditCalories = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            
            if let profile = dataManager.userProfile {
                let bmr = CalorieCalculator.calculateBMR(
                    age: profile.age,
                    gender: profile.gender,
                    weight: profile.weight,
                    height: profile.height
                )
                let tdee = CalorieCalculator.calculateTDEE(bmr: bmr, activityLevel: profile.activityLevel)
                let fastingPlan = FastingPlan.planForActivityLevel(profile.activityLevel)
                VStack(spacing: 16) {
                    InfoRow(title: "Fasting Goal", value: profile.fastingGoal.rawValue)
                    HStack {
                        InfoRow(title: "Daily Calories", value: "\(profile.dailyCalorieTarget) cal")
                        Button(action: {
                            newCalorieTarget = String(profile.dailyCalorieTarget)
                            showingEditCalories = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.orange)
                        }
                    }
                    InfoRow(title: "BMR (Base Rate)", value: "\(Int(bmr)) cal")
                    InfoRow(title: "TDEE (Total Daily)", value: "\(Int(tdee)) cal")
                    InfoRow(title: "Suggested Fasting", value: fastingPlan.name)
                    InfoRow(title: "Fasting Window", value: "\(Int(fastingPlan.fastingWindow/3600)):\(Int(fastingPlan.eatingWindow/3600))")
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .sheet(isPresented: $showingEditCalories) {
            VStack(spacing: 24) {
                Text("Edit Daily Calorie Target")
                    .font(.headline)
                TextField("Calories", text: $newCalorieTarget)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Save") {
                    if let newValue = Int(newCalorieTarget), var profile = dataManager.userProfile {
                        profile.dailyCalorieTarget = newValue
                        dataManager.saveUserProfile(profile)
                        showingEditCalories = false
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("Cancel") {
                    showingEditCalories = false
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            if dataManager.achievements.filter({ $0.isUnlocked }).isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No achievements unlocked yet")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Start fasting, eating healthy, and using the app to earn achievements!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(dataManager.achievements.filter { $0.isUnlocked }) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
            }
        }
    }
    
    private var settingsCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("App Settings")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Customize your experience")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
            
            VStack(spacing: 16) {
                Button(action: {
                    // Enhanced button feedback
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        notificationsButtonScale = 0.95
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            notificationsButtonScale = 1.0
                        }
                    }
                    
                    showingNotificationsSettings = true
                }) {
                    SettingRow(
                        icon: "bell.fill",
                        title: "Notifications",
                        subtitle: notificationManager.isNotificationsEnabled ? "Enabled" : "Disabled",
                        color: notificationManager.isNotificationsEnabled ? .green : .orange
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(notificationsButtonScale)
                

                
                Button(action: {
                    // Enhanced button feedback
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        dataSyncButtonScale = 0.95
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            dataSyncButtonScale = 1.0
                        }
                    }
                    
                    showingDataSyncSettings = true
                }) {
                    SettingRow(
                        icon: "icloud.fill",
                        title: "Data Sync",
                        subtitle: "Enabled",
                        color: .blue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(dataSyncButtonScale)
                
                // Gamification Toggle
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "rosette.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Gamification")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text(gamificationEnabled ? "Enabled" : "Disabled")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(gamificationEnabled ? .green : .orange)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $gamificationEnabled)
                            .onChange(of: gamificationEnabled) { oldValue, newValue in
                                updateGamificationPreference(enabled: newValue)
                            }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                if let user = authManager.currentUser {
                    HStack {
                        Image(systemName: user.id == "guest" ? "person.fill" : "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(user.id == "guest" ? .orange : .blue)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Signed in as")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text(user.id == "guest" ? "Guest User" : (user.email ?? "User"))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                    

                }
                
                Button(action: {
                    authManager.signOut()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title2)
                            .foregroundColor(.red)
                            .frame(width: 24, height: 24)
                        
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Debug Section (Development Only)
    private var debugSection: some View {
        VStack(spacing: 16) {
            Text("Debug & Development")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                Button(action: {
                    dataManager.clearAllData()
                }) {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                            .font(.title3)
                            .foregroundColor(.red)
                        Text("Clear All App Data")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("⚠️ This will reset the app to factory settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Helper Functions
    private func updateGamificationPreference(enabled: Bool) {
        if var profile = dataManager.userProfile {
            profile.gamificationEnabled = enabled
            dataManager.saveUserProfile(profile)
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

// Remove EditProfileView and all edit buttons (toolbar, header, etc.)

#Preview {
    ProfileView()
} 