import SwiftUI

struct FastingView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var fastingScience = FastingScienceService.shared
    @State private var timer: Timer?
    @State private var animateProgress = false
    @State private var showContent = false
    @State private var showScienceInfo = false
    @State private var currentTime = Date()
    
    // Animation states for all buttons
    @State private var settingsButtonScale: CGFloat = 1.0
    @State private var fastingStatusButtonScale: CGFloat = 1.0
    @State private var startStopButtonScale: CGFloat = 1.0
    @State private var startStopButtonRotation: Double = 0.0
    @State private var historyButtonScale: CGFloat = 1.0
    @State private var infoButtonScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Fasting Status Card
                    fastingStatusCard
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                    
                    // Progress Visualization
                    progressVisualization
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 40)
                    
                    // Fasting Phase Info
                    fastingPhaseInfo
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 50)
                    
                    // Science Info Card
                    scienceInfoCard
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 55)
                    
                    // Action Buttons
                    actionButtons
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 60)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGray6))
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    showContent = true
                }
                startTimer()
                
                // Debug information
                print("DEBUG: FastingView appeared")
                print("DEBUG: userProfile: \(dataManager.userProfile != nil ? "exists" : "nil")")
                if let profile = dataManager.userProfile {
                    print("DEBUG: User profile - name: \(profile.name), activityLevel: \(profile.activityLevel.rawValue)")
                }
            }
            .onDisappear {
                stopTimer()
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Fasting")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Track your fasting journey")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // Settings action - navigate to profile settings
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    settingsButtonScale = 0.9
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        settingsButtonScale = 1.0
                    }
                }
                
                // Navigate to profile tab for settings
                NotificationCenter.default.post(name: .init("NavigateToProfile"), object: nil)
            }) {
                Image(systemName: "timer.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .scaleEffect(settingsButtonScale)
        }
        .padding(.top, 20)
    }
    
    private var fastingStatusCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Status")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Real-time fasting progress")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            
            if let session = dataManager.currentFastingSession, session.isActive {
                // Active fasting session
                VStack(spacing: 20) {
                    // Large progress ring
                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 12)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: session.progress)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue, .cyan, .green],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 200, height: 200)
                            .animation(.easeInOut(duration: 1), value: session.progress)
                        
                        VStack(spacing: 2) {
                            Text(timeString(from: session.elapsedTime))
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary)
                                .id(currentTime) // Force refresh when currentTime changes
                                .frame(width: 140, alignment: .center) // Fixed width within ring bounds
                                .lineLimit(1)
                                .minimumScaleFactor(0.7) // Allow text to scale down if needed
                            
                            Text("elapsed")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            // Ketosis indicator
                            if session.elapsedTime >= 18 * 3600 { // 18 hours
                                HStack(spacing: 3) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.orange)
                                    Text("KETOSIS")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.orange)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.orange.opacity(0.2))
                                )
                            }
                        }
                        .frame(width: 160) // Constrain content to fit within ring
                    }
                    
                    // Time details
                    HStack(spacing: 40) {
                        VStack(spacing: 6) {
                            Text(timeString(from: session.remainingTime))
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                                .id(currentTime) // Force refresh when currentTime changes
                                .frame(minWidth: 80, alignment: .center) // Fixed width to prevent movement
                            Text("remaining")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 6) {
                            Text("\(Int(session.progress * 100))%")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.blue)
                            Text("complete")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 6) {
                            Text(formatTime(session.startTime))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.green)
                            Text("started")
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
                        print("DEBUG: Started fasting session from status card with plan: \(plan.name), duration: \(plan.fastingWindow/3600) hours")
                    } else {
                        print("DEBUG: User profile is nil - cannot start fasting session from status card")
                        // Fallback to default plan if no profile exists
                        let defaultPlan = FastingPlan.planForActivityLevel(.moderatelyActive)
                        dataManager.startFastingSession(targetDuration: defaultPlan.fastingWindow)
                        print("DEBUG: Using fallback plan: \(defaultPlan.name), duration: \(defaultPlan.fastingWindow/3600) hours")
                    }
                }) {
                    VStack(spacing: 20) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("Ready to Start Fasting?")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            if dataManager.userProfile == nil {
                                Text("Complete your profile setup for personalized fasting plans")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.orange)
                                    .multilineTextAlignment(.center)
                            } else {
                            Text("Begin your fasting journey to unlock the incredible benefits of intermittent fasting")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                .scaleEffect(fastingStatusButtonScale)
                .buttonStyle(PlainButtonStyle())
                
                // Show setup profile button if no profile exists
                if dataManager.userProfile == nil {
                    Button(action: {
                        // Navigate to profile tab for setup
                        NotificationCenter.default.post(name: .init("NavigateToProfile"), object: nil)
                    }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                            Text("Complete Profile Setup")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 12)
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
    
    private var progressVisualization: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress Overview")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Your fasting journey")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
            
            if let session = dataManager.currentFastingSession, session.isActive {
                VStack(spacing: 16) {
                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .trim(from: 0, to: session.progress)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [.blue, .green, .orange]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 100, height: 100)
                            .animation(.easeInOut(duration: 1), value: session.progress)
                        
                        VStack {
                            Text("\(Int(session.progress * 100))%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            Text("complete")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Progress details
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("\(Int(session.elapsedTime / 3600))h")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.blue)
                            Text("elapsed")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(Int(session.remainingTime / 3600))h")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.orange)
                            Text("remaining")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(Int(session.targetDuration / 3600))h")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                            Text("target")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No active fasting session")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Start a fasting session to see your progress")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var fastingPhaseInfo: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fasting Phases")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Understanding your journey")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // Current Phase Indicator
            if let session = dataManager.currentFastingSession, session.isActive {
                let currentPhase = getCurrentFastingPhase(hours: session.elapsedTime / 3600)
                let isInKetosis = session.elapsedTime >= 18 * 3600 // 18 hours
                
                VStack(spacing: 16) {
                    // Current Phase Card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Phase")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(currentPhase.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(currentPhase.color)
                        }
                        
                        Spacer()
                        
                        if isInKetosis {
                            HStack(spacing: 8) {
                                Image(systemName: "flame.fill")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                Text("KETOSIS")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(currentPhase.color.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(currentPhase.color.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Phase Description
                    Text(currentPhase.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 4)
                }
            }
            
            VStack(spacing: 12) {
                FastingPhaseRow(
                    phase: "Fat Burning",
                    description: "12-18 hours",
                    color: .green,
                    isActive: getCurrentFastingPhase(hours: (dataManager.currentFastingSession?.elapsedTime ?? 0) / 3600).name == "Fat Burning"
                )
                
                FastingPhaseRow(
                    phase: "Ketosis",
                    description: "18-24 hours",
                    color: .orange,
                    isActive: getCurrentFastingPhase(hours: (dataManager.currentFastingSession?.elapsedTime ?? 0) / 3600).name == "Ketosis"
                )
                
                FastingPhaseRow(
                    phase: "Autophagy",
                    description: "24+ hours",
                    color: .purple,
                    isActive: getCurrentFastingPhase(hours: (dataManager.currentFastingSession?.elapsedTime ?? 0) / 3600).name == "Autophagy"
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    @State private var showingLogFasting = false
    @State private var showingStartFastingFromTime = false
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Start/Stop fasting button
            Button(action: {
                // Enhanced button feedback
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    startStopButtonScale = 0.95
                    startStopButtonRotation = 5.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        startStopButtonScale = 1.0
                        startStopButtonRotation = 0.0
                    }
                }
                
                if let session = dataManager.currentFastingSession, session.isActive {
                    dataManager.endFastingSession()
                } else {
                    if let profile = dataManager.userProfile {
                        let plan = FastingPlan.planForActivityLevel(profile.activityLevel)
                        dataManager.startFastingSession(targetDuration: plan.fastingWindow)
                        print("DEBUG: Started fasting session with plan: \(plan.name), duration: \(plan.fastingWindow/3600) hours")
                    } else {
                        print("DEBUG: User profile is nil - cannot start fasting session")
                        // Fallback to default plan if no profile exists
                        let defaultPlan = FastingPlan.planForActivityLevel(.moderatelyActive)
                        dataManager.startFastingSession(targetDuration: defaultPlan.fastingWindow)
                        print("DEBUG: Using fallback plan: \(defaultPlan.name), duration: \(defaultPlan.fastingWindow/3600) hours")
                    }
                }
            }) {
                HStack {
                    Image(systemName: dataManager.currentFastingSession?.isActive == true ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .rotationEffect(.degrees(startStopButtonRotation))
                    Text(dataManager.currentFastingSession?.isActive == true ? "Stop Fasting" : "Start Fasting")
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
                            dataManager.currentFastingSession?.isActive == true ?
                            LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
                        )
                )
            }
            .scaleEffect(startStopButtonScale)
            .buttonStyle(PlainButtonStyle())
            
            // Start Fasting From Time button (only show when no active session)
            if dataManager.currentFastingSession?.isActive != true {
                Button(action: {
                    showingStartFastingFromTime = true
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                        Text("Start Fasting From Time")
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
                                LinearGradient(colors: [.indigo, .blue], startPoint: .leading, endPoint: .trailing)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Log Past Fasting button
            Button(action: {
                showingLogFasting = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("Log Past Fasting")
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
                            LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // View history button
            Button(action: {
                // Enhanced button feedback
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    historyButtonScale = 0.95
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        historyButtonScale = 1.0
                    }
                }
                
                // Navigate to history
            }) {
                HStack {
                    Image(systemName: "clock.circle.fill")
                        .font(.title2)
                    Text("View History")
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
                            LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                        )
                )
            }
            .scaleEffect(historyButtonScale)
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showingLogFasting) {
            LogFastingView()
        }
        .sheet(isPresented: $showingStartFastingFromTime) {
            StartFastingFromTimeView()
        }
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
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.currentTime = Date()
            }
        }
    }
    
    private var scienceInfoCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fasting Science")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Understanding ketosis and fat burning")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    // Enhanced button feedback
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        infoButtonScale = 0.9
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            infoButtonScale = 1.0
                        }
                    }
                    
                    showScienceInfo.toggle()
                }) {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .scaleEffect(infoButtonScale)
            }
            
            if let session = dataManager.currentFastingSession, session.isActive {
                let hours = Int(session.elapsedTime / 3600)
                let ketoneInfo = fastingScience.getKetoneLevel(hours: hours)
                let fatBurningInfo = fastingScience.getFatBurningStatus(hours: hours)
                let benefits = fastingScience.getBenefitsByDuration(hours: hours)
                
                VStack(spacing: 16) {
                    // Current Phase Info
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text("\(hours)h")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.blue)
                            Text("Fasting")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text(ketoneInfo.level)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.orange)
                            Text("Ketones")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(Int(fatBurningInfo.percentage * 100))%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                            Text("Fat Burning")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Progress bar for fat burning
                    VStack(spacing: 8) {
                        HStack {
                            Text("Fat Burning Progress")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                            Text(fatBurningInfo.status)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray4))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * fatBurningInfo.percentage, height: 8)
                                    .animation(.easeInOut(duration: 1), value: fatBurningInfo.percentage)
                            }
                        }
                        .frame(height: 8)
                    }
                    
                    // Current Benefits
                    if !benefits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Benefits:")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            ForEach(benefits.prefix(3), id: \.self) { benefit in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.green)
                                    Text(benefit)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "flame.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Ready for Fat Burning")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Start fasting to begin your journey to ketosis and enhanced fat burning")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .sheet(isPresented: $showScienceInfo) {
            FastingScienceInfoView()
        }
    }
    
    private func getCurrentFastingPhase(hours: Double) -> (name: String, color: Color, description: String) {
        switch hours {
        case 0..<12:
            return ("Early Fasting", .blue, "Your body is still using glucose from your last meal. Insulin levels are high.")
        case 12..<18:
            return ("Fat Burning", .green, "Your body is switching to fat burning! Glycogen stores are depleting.")
        case 18..<24:
            return ("Ketosis", .orange, "You're in ketosis! Your body is now primarily burning fat for energy.")
        case 24..<48:
            return ("Autophagy", .purple, "Autophagy is active! Your body is cleaning up damaged cells.")
        default:
            return ("Extended Fasting", .red, "Extended fasting benefits! Enhanced autophagy and fat burning.")
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct FastingPhaseRow: View {
    let phase: String
    let description: String
    let color: Color
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(isActive ? color : Color(.systemGray4))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(phase)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isActive {
                Text("Active")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color.opacity(0.1))
                    )
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    FastingView()
} 