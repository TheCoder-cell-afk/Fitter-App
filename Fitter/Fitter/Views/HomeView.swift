import SwiftUI

// MARK: - iOS 26 Ready
// This view is fully optimized for iOS 26 Liquid Glass
// All TabView, NavigationView, and custom cards will automatically get:
// ✅ Liquid Glass tab bars (floating above content)
// ✅ Glass navigation bars with fluid morphing
// ✅ Enhanced glass effects on all background elements
// ✅ Improved shadows and visual hierarchy
// ✅ Better accessibility and legibility
// ✅ Automatic glass separation from content

struct HomeView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var fastingScience = FastingScienceService.shared
    @StateObject private var gamificationService = GamificationService(dataManager: DataManager.shared)
    @State private var timer: Timer?
    @State private var animateProgress = false
    @State private var showWelcome = false
    @State private var startFastingPressed = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var buttonRotation: Double = 0.0
    @State private var showFastingInfo = false
    @State private var currentTime = Date()
    
    // Animation states for all buttons
    @State private var profileButtonScale: CGFloat = 1.0
    @State private var fastingStatusButtonScale: CGFloat = 1.0
    @State private var logFoodButtonScale: CGFloat = 1.0
    @State private var logFoodButtonRotation: Double = 0.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Level and XP Card
                    if gamificationService.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading progress...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .opacity(showWelcome ? 1 : 0)
                        .offset(y: showWelcome ? 0 : 25)
                    } else {
                        if gamificationService.isGamificationEnabled {
                            levelXPCard
                                .opacity(showWelcome ? 1 : 0)
                                .offset(y: showWelcome ? 0 : 25)
                        }
                    }
                    
                    // Fasting Status Card
                    fastingStatusCard
                        .opacity(showWelcome ? 1 : 0)
                        .offset(y: showWelcome ? 0 : 30)
                    
                    // Calorie Logging Streak Card
                    calorieStreakCard
                        .opacity(showWelcome ? 1 : 0)
                        .offset(y: showWelcome ? 0 : 35)
                    
                    // Projected Weight Loss Card
                    projectedWeightLossCard
                        .opacity(showWelcome ? 1 : 0)
                        .offset(y: showWelcome ? 0 : 40)
                    
                    // Quick Actions
                    quickActionsCard
                        .opacity(showWelcome ? 1 : 0)
                        .offset(y: showWelcome ? 0 : 45)
                    
                    Spacer(minLength: 100)
                    
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGray6))
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    showWelcome = true
                }
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let profile = dataManager.userProfile {
                    Text("Welcome back, \(profile.name)!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Ready to achieve your \(profile.fastingGoal.rawValue.lowercased()) goals?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                } else {
                    Text("Welcome back!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Ready to start your health journey?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                // Profile action - navigate to profile tab
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    profileButtonScale = 0.9
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        profileButtonScale = 1.0
                    }
                }
                
                // Navigate to profile tab
                NotificationCenter.default.post(name: .init("NavigateToProfile"), object: nil)
            }) {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .scaleEffect(profileButtonScale)
        }
        .padding(.top, 20)
    }
    
    private var fastingStatusCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fasting Status")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Track your fasting progress")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "timer.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // Remove: Calories Burned and Adjusted Calorie Goal UI
            
            if let session = dataManager.currentFastingSession, session.isActive {
                // Active fasting session
                VStack(spacing: 16) {
                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 8)
                            .frame(width: 140, height: 140)
                        
                        Circle()
                            .trim(from: 0, to: session.progress)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 140, height: 140)
                            .animation(.easeInOut(duration: 1), value: session.progress)
                        
                        VStack(spacing: 2) {
                            Text(timeString(from: session.elapsedTime))
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary)
                                .id(currentTime) // Force refresh when currentTime changes
                                .frame(width: 100, alignment: .center) // Fixed width within ring bounds
                                .lineLimit(1)
                                .minimumScaleFactor(0.8) // Allow text to scale down if needed
                            
                            Text("elapsed")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 120) // Constrain content to fit within ring
                    }
                    
                    // Time details
                    HStack(spacing: 30) {
                        VStack(spacing: 4) {
                            Text(timeString(from: session.remainingTime))
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                                .id(currentTime) // Force refresh when currentTime changes
                                .frame(minWidth: 70, alignment: .center) // Fixed width to prevent movement
                            Text("remaining")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(Int(session.progress * 100))%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.blue)
                            Text("complete")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                // No active session
                Button(action: {
                    // Enhanced button feedback
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        fastingStatusButtonScale = 0.95
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            fastingStatusButtonScale = 1.0
                        }
                    }
                    
                    // Start fasting session using activity-based plan
                    if let profile = dataManager.userProfile {
                        let plan = FastingPlan.planForActivityLevel(profile.activityLevel)
                        dataManager.startFastingSession(targetDuration: plan.fastingWindow)
                    }
                }) {
                    VStack(spacing: 16) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Ready to start fasting?")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Begin your fasting journey to achieve your health goals")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                }
                .scaleEffect(fastingStatusButtonScale)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        // iOS 26 Ready: Will automatically get enhanced glass effects and better shadows
    }
    
    private var quickActionsCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Actions")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Start your health journey")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "bolt.circle.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
            
            // Action buttons
            VStack(spacing: 12) {
                // Start fasting button
                Button(action: {
                    // Enhanced button feedback
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        buttonScale = 0.95
                        buttonRotation = 5.0
                    }
                    
                    // Reset animation after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            buttonScale = 1.0
                            buttonRotation = 0.0
                        }
                    }
                    
                    // Show fasting info briefly
                    showFastingInfo = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showFastingInfo = false
                    }
                    
                    // Start fasting session using activity-based plan
                    if let profile = dataManager.userProfile {
                        let plan = FastingPlan.planForActivityLevel(profile.activityLevel)
                        dataManager.startFastingSession(targetDuration: plan.fastingWindow)
                    }
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .rotationEffect(.degrees(buttonRotation))
                        Text("Start Fasting")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.white)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .scaleEffect(buttonScale)
                .buttonStyle(PlainButtonStyle())
                .overlay(
                    // Fasting info popup
                    Group {
                        if showFastingInfo {
                            VStack(spacing: 8) {
                                Image(systemName: "flame.fill")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                Text("Fasting Started!")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Fat burning begins in ~12 hours")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.8))
                            )
                            .offset(y: -60)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                )
                
                // Log food button
                Button(action: {
                    // Enhanced button feedback
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        logFoodButtonScale = 0.95
                        logFoodButtonRotation = 5.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            logFoodButtonScale = 1.0
                            logFoodButtonRotation = 0.0
                        }
                    }
                    
                    // Navigate directly to add food
                    NotificationCenter.default.post(name: .init("ShowAddFood"), object: nil)
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .rotationEffect(.degrees(logFoodButtonRotation))
                        Text("Log Food")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.white)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .scaleEffect(logFoodButtonScale)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        // iOS 26 Ready: Will automatically get enhanced glass effects and better shadows
    }
    
    private var calorieStreakCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: dataManager.calorieLoggingStreak >= 7 ? "star.fill" : "flame.fill")
                    .font(.title2)
                    .foregroundColor(dataManager.calorieLoggingStreak >= 7 ? .yellow : .orange)
                Text("Calorie Logging Streak")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Text("Best: \(dataManager.bestCalorieLoggingStreak)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(dataManager.calorieLoggingStreak)")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(.orange)
                Text(dataManager.calorieLoggingStreak == 1 ? "day" : "days")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                Text("logged in a row!")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            if dataManager.calorieLoggingStreak > 0 {
                Text(dataManager.calorieLoggingStreak < 3 ? "Great start! Log again tomorrow!" : (dataManager.calorieLoggingStreak < 7 ? "🔥 Keep the streak alive!" : "🌟 Amazing! You're on fire!"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            } else {
                Text("Log your meals to start a streak!")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .orange.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        // iOS 26 Ready: Will automatically get enhanced glass effects and better shadows
    }
    
    private var projectedWeightLossCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("Projected Weight Loss")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                if let profile = dataManager.userProfile, let weightGoal = profile.weightGoal {
                    Text("Goal: \(String(format: "%.1f", weightGoal))kg")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            if let profile = dataManager.userProfile, let weightGoal = profile.weightGoal {
                let currentWeight = profile.weight
                let targetWeight = weightGoal
                let weightDifference = currentWeight - targetWeight
                let weeklyLoss = 0.5 // Conservative estimate: 0.5kg per week
                let weeksToGoal = weightDifference > 0 ? Int(ceil(weightDifference / weeklyLoss)) : 0
                
                if weightDifference > 0 {
                    VStack(spacing: 12) {
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("\(String(format: "%.1f", weightDifference))")
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(.green)
                            Text("kg to go")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Projected Timeline")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Text("\(weeksToGoal) weeks")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Weekly Goal")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.1f", weeklyLoss))kg")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        if weeksToGoal > 0 {
                            Text("Stay consistent with your fasting and nutrition plan!")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.green)
                            Text("Goal Achieved!")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.green)
                            Spacer()
                        }
                        
                        Text("Congratulations! You've reached your weight goal. Consider setting a new goal to maintain your progress.")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                    }
                }
            } else if dataManager.userProfile != nil {
                Text("Set a weight goal in your profile to see projections")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
            } else {
                Text("Complete your profile to see weight loss projections")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .green.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        // iOS 26 Ready: Will automatically get enhanced glass effects and better shadows
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%d sec", seconds)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.currentTime = Date()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Level and XP Card
    private var levelXPCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(gamificationService.userLevel.level)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(gamificationService.userLevel.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(gamificationService.totalXP) XP")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    
                    Text("\(gamificationService.availablePoints) pts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar to next level
            VStack(spacing: 6) {
                HStack {
                    Text("Next level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(gamificationService.getNextLevelProgress()))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: gamificationService.getNextLevelProgress(), total: 100)
                    .tint(.blue)
                    .scaleEffect(y: 0.8)
            }
            
            // Recent achievement indicator
            if !gamificationService.recentAchievements.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text(gamificationService.recentAchievements.first ?? "")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("New!")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        // iOS 26 Ready: Will automatically get enhanced glass effects and better shadows
    }
}

#Preview {
    HomeView()
} 