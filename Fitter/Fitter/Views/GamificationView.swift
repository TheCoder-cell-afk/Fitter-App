import SwiftUI

struct GamificationView: View {
    @StateObject private var gamificationService = GamificationService(dataManager: DataManager.shared)
    @State private var selectedTab: GamificationTab = .overview
    @State private var showingBadgeDetail: Badge?
    @State private var showingRewardStore = false
    @State private var showingChallengeDetail: Challenge?
    
    enum GamificationTab: String, CaseIterable {
        case overview = "Overview"
        case badges = "Badges"
        case challenges = "Challenges"
        case leaderboard = "Leaderboard"
        case rewards = "Rewards"
        
        var icon: String {
            switch self {
            case .overview: return "chart.bar.fill"
            case .badges: return "rosette"
            case .challenges: return "target"
            case .leaderboard: return "list.number"
            case .rewards: return "gift.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                tabSelector
                
                // Content
                if gamificationService.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading your progress...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top)
                        Spacer()
                    }
                } else if !gamificationService.isGamificationEnabled {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "rosette")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("Gamification Disabled")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("You chose to disable gamification features during onboarding. You can enable them in your profile settings.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button(action: {
                            // Navigate to profile to enable gamification
                            NotificationCenter.default.post(name: .init("NavigateToProfile"), object: nil)
                        }) {
                            Text("Go to Profile")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            switch selectedTab {
                            case .overview:
                                overviewContent
                            case .badges:
                                badgesContent
                            case .challenges:
                                challengesContent
                            case .leaderboard:
                                leaderboardContent
                            case .rewards:
                                rewardsContent
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $showingBadgeDetail) { badge in
                BadgeDetailView(badge: badge)
            }
            .sheet(isPresented: $showingRewardStore) {
                RewardStoreView(gamificationService: gamificationService)
            }
            .sheet(item: $showingChallengeDetail) { challenge in
                ChallengeDetailView(challenge: challenge)
            }
        }
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(GamificationTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.title3)
                                .foregroundColor(selectedTab == tab ? .white : .primary)
                            
                            Text(tab.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedTab == tab ? .white : .primary)
                        }
                        .frame(width: 80, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTab == tab ? Color.blue : Color(.systemGray6))
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Overview Content
    private var overviewContent: some View {
        VStack(spacing: 20) {
            // Level Progress
            levelProgressCard
            
            // XP and Streaks
            xpAndStreaksCard
            
            // Recent Achievements
            recentAchievementsCard
            
            // Quick Stats
            quickStatsCard
        }
    }
    
    private var levelProgressCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Level Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Rewards") {
                    showingRewardStore = true
                }
                .font(.footnote)
                .foregroundColor(.blue)
            }
            
            HStack(spacing: 20) {
                // Level Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: gamificationService.getNextLevelProgress() / 100)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: gamificationService.getNextLevelProgress())
                    
                    Text("\(gamificationService.userLevel.level)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(gamificationService.userLevel.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Level \(gamificationService.userLevel.level)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: gamificationService.getNextLevelProgress(), total: 100)
                        .tint(.blue)
                    
                    Text("\(gamificationService.userLevel.xpProgress) / \(gamificationService.userLevel.xpRequired) XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Level Benefits
            if !gamificationService.userLevel.benefits.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Benefits")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ForEach(gamificationService.userLevel.benefits.prefix(3), id: \.self) { benefit in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text(benefit)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    private var xpAndStreaksCard: some View {
        VStack(spacing: 16) {
            Text("Today's Progress")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                // XP Progress
                VStack(alignment: .leading, spacing: 8) {
                    Text("XP Today")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("\(gamificationService.getTodayXP())")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("/ \(gamificationService.getDailyXPGoal())")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(
                        value: Double(gamificationService.getTodayXP()),
                        total: Double(gamificationService.getDailyXPGoal())
                    )
                    .tint(.orange)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // Points Available
                VStack(alignment: .leading, spacing: 8) {
                    Text("Points")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("\(gamificationService.availablePoints)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Button("Spend") {
                        showingRewardStore = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Top Streaks
            if !gamificationService.streaks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Streaks")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(gamificationService.streaks.filter { $0.isActive }.prefix(4), id: \.type) { streak in
                            StreakCard(streak: streak)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var recentAchievementsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Achievements")
                .font(.headline)
                .fontWeight(.semibold)
            
            if gamificationService.recentAchievements.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("Keep going!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Complete activities to unlock achievements")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                ForEach(gamificationService.recentAchievements.prefix(3), id: \.self) { achievement in
                    HStack(spacing: 12) {
                        Image(systemName: "star.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.title3)
                        
                        Text(achievement)
                            .font(.footnote)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("New")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var quickStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Stats")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(
                    title: "Total XP",
                    value: "\(gamificationService.totalXP)",
                    icon: "star.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Badges",
                    value: "\(gamificationService.badges.filter { $0.isUnlocked }.count)",
                    icon: "rosette",
                    color: .purple
                )
                
                StatCard(
                    title: "Challenges",
                    value: "\(gamificationService.challenges.filter { $0.isCompleted }.count)",
                    icon: "target",
                    color: .green
                )
                
                StatCard(
                    title: "Best Streak",
                    value: "\(gamificationService.streaks.map { $0.best }.max() ?? 0)",
                    icon: "flame.fill",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Badges Content
    private var badgesContent: some View {
        VStack(spacing: 20) {
            // Badge Progress Summary
            badgeProgressSummary
            
            // Badge Categories
            badgeCategoriesGrid
        }
    }
    
    private var badgeProgressSummary: some View {
        VStack(spacing: 16) {
            Text("Badge Collection")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let unlockedCount = gamificationService.badges.filter { $0.isUnlocked }.count
            let totalCount = gamificationService.badges.count
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Collected")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("\(unlockedCount) / \(totalCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: Double(unlockedCount) / Double(totalCount),
                    lineWidth: 6,
                    size: 60
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var badgeCategoriesGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ForEach(Badge.BadgeCategory.allCases, id: \.self) { category in
                BadgeCategoryCard(
                    category: category,
                    badges: gamificationService.badges.filter { $0.category == category },
                    onBadgeTap: { badge in
                        showingBadgeDetail = badge
                    }
                )
            }
        }
    }
    
    // MARK: - Challenges Content
    private var challengesContent: some View {
        VStack(spacing: 20) {
            // Active Challenges
            activeChallengesSection
            
            // Challenge Ideas
            challengeIdeasSection
        }
    }
    
    private var activeChallengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Challenges")
                .font(.headline)
                .fontWeight(.semibold)
            
            if gamificationService.challenges.filter({ $0.isActive }).isEmpty {
                ChallengesPlaceholder()
            } else {
                ForEach(gamificationService.challenges.filter { $0.isActive }, id: \.id) { challenge in
                    ChallengeCard(challenge: challenge) {
                        showingChallengeDetail = challenge
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var challengeIdeasSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Challenge Ideas")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Complete more activities to unlock new challenges!")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ChallengeIdeaCard(
                    title: "30-Day Streak",
                    description: "Log daily for 30 days",
                    icon: "calendar.badge.checkmark",
                    color: .green,
                    isLocked: true
                )
                
                ChallengeIdeaCard(
                    title: "Marathon Month",
                    description: "Run 100km in 30 days",
                    icon: "figure.run",
                    color: .blue,
                    isLocked: true
                )
                
                ChallengeIdeaCard(
                    title: "Hydration Hero",
                    description: "Perfect hydration for 2 weeks",
                    icon: "drop.fill",
                    color: .cyan,
                    isLocked: true
                )
                
                ChallengeIdeaCard(
                    title: "Fasting Master",
                    description: "Complete 10 perfect fasts",
                    icon: "clock.badge",
                    color: .orange,
                    isLocked: true
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Leaderboard Content
    private var leaderboardContent: some View {
        VStack(spacing: 20) {
            leaderboardSection
        }
    }
    
    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Global Leaderboard")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Weekly") {
                    // Switch to weekly view
                }
                .font(.footnote)
                .foregroundColor(.blue)
            }
            
            if gamificationService.leaderboard.isEmpty {
                LeaderboardPlaceholder()
            } else {
                ForEach(Array(gamificationService.leaderboard.enumerated()), id: \.offset) { index, entry in
                    LeaderboardRow(entry: entry, isCurrentUser: entry.userId == "current")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Rewards Content
    private var rewardsContent: some View {
        VStack(spacing: 20) {
            // Points Balance
            pointsBalanceCard
            
            // Available Rewards
            availableRewardsSection
        }
    }
    
    private var pointsBalanceCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Reward Points")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Store") {
                    showingRewardStore = true
                }
                .font(.footnote)
                .foregroundColor(.blue)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Available")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("\(gamificationService.availablePoints)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Total Earned")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("\(gamificationService.totalXP)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    private var availableRewardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Rewards")
                .font(.headline)
                .fontWeight(.semibold)
            
            let availableRewards = gamificationService.rewards.filter { $0.isUnlocked && !$0.isPurchased }
            
            if availableRewards.isEmpty {
                RewardsPlaceholder()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(availableRewards.prefix(6), id: \.id) { reward in
                        RewardCard(reward: reward, gamificationService: gamificationService)
                    }
                }
                
                if availableRewards.count > 6 {
                    Button("View All Rewards") {
                        showingRewardStore = true
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Supporting Views
struct StreakCard: View {
    let streak: Streak
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: streak.type.icon)
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text("\(streak.current)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            
            Text(streak.type.title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
    }
}

struct BadgeCategoryCard: View {
    let category: Badge.BadgeCategory
    let badges: [Badge]
    let onBadgeTap: (Badge) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(categoryTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(badges.filter { $0.isUnlocked }.count)/\(badges.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(badges.prefix(6), id: \.id) { badge in
                    Button(action: {
                        onBadgeTap(badge)
                    }) {
                        BadgeMiniView(badge: badge)
                    }
                }
                
                if badges.count > 6 {
                    VStack {
                        Text("+\(badges.count - 6)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    private var categoryTitle: String {
        switch category {
        case .nutrition: return "Nutrition"
        case .exercise: return "Exercise"
        case .hydration: return "Hydration"
        case .fasting: return "Fasting"
        case .consistency: return "Consistency"
        case .achievement: return "Achievement"
        case .social: return "Social"
        }
    }
}

struct BadgeMiniView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: badge.iconName)
                .font(.title3)
                .foregroundColor(badge.isUnlocked ? rarityColor : .gray)
                .opacity(badge.isUnlocked ? 1.0 : 0.4)
            
            if !badge.isUnlocked && badge.progress > 0 {
                ProgressView(value: badge.progress, total: 100)
                    .scaleEffect(0.8)
                    .tint(rarityColor)
            }
        }
        .frame(width: 40, height: 40)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(badge.isUnlocked ? rarityColor : Color.clear, lineWidth: 1)
        )
    }
    
    private var rarityColor: Color {
        switch badge.rarity.color {
        case "gray": return .gray
        case "blue": return .blue
        case "purple": return .purple
        case "gold": return .yellow
        default: return .gray
        }
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: challenge.type.icon)
                        .foregroundColor(getTypeColor(challenge.type))
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(challenge.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(challenge.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(challenge.progressPercentage))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(getTypeColor(challenge.type))
                }
                
                ProgressView(value: challenge.progress, total: challenge.target)
                    .tint(getTypeColor(challenge.type))
                
                HStack {
                    Text("\(Int(challenge.progress)) / \(Int(challenge.target)) \(challenge.type.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if challenge.timeRemaining > 0 {
                        Text(timeRemainingString(challenge.timeRemaining))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Expired")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getTypeColor(_ type: Challenge.ChallengeType) -> Color {
        switch type {
        case .steps: return .green
        case .exercise: return .blue
        case .fasting: return .orange
        case .hydration: return .cyan
        case .calories: return .red
        case .consistency: return .purple
        }
    }
    
    private func timeRemainingString(_ timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval / 86400)
        let hours = Int((timeInterval.truncatingRemainder(dividingBy: 86400)) / 3600)
        
        if days > 0 {
            return "\(days)d \(hours)h left"
        } else if hours > 0 {
            return "\(hours)h left"
        } else {
            return "< 1h left"
        }
    }
}

struct ChallengeIdeaCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isLocked: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isLocked ? .gray : color)
                    .font(.title3)
                
                Spacer()
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(isLocked ? .gray : .primary)
            
            Text(description)
                .font(.caption)
                .foregroundColor(isLocked ? .gray : .secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(isLocked ? 0.6 : 1.0)
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(entry.rank)")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(isCurrentUser ? .blue : .secondary)
                .frame(width: 30, alignment: .leading)
            
            // Badge/Avatar
            if let badge = entry.badge {
                Text(badge)
                    .font(.title3)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text(String(entry.username.prefix(1)))
                            .font(.caption)
                            .fontWeight(.bold)
                    )
            }
            
            // Username
            Text(entry.username)
                .font(.footnote)
                .fontWeight(isCurrentUser ? .semibold : .medium)
                .foregroundColor(isCurrentUser ? .blue : .primary)
            
            Spacer()
            
            // Score
            Text("\(entry.score) XP")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(isCurrentUser ? .blue : .secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isCurrentUser ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

struct RewardCard: View {
    let reward: Reward
    let gamificationService: GamificationService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(reward.name)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Spacer()
                
                Button("Buy") {
                    _ = gamificationService.purchaseReward(reward)
                }
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(gamificationService.availablePoints >= reward.cost ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(4)
                .disabled(gamificationService.availablePoints < reward.cost)
            }
            
            Text(reward.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text("\(reward.cost) points")
                    .font(.caption2)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(reward.type.category)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Placeholder Views
struct ChallengesPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "target")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("No active challenges")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Check back later for new challenges!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LeaderboardPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.number")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("Leaderboard loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Compete with friends and see your ranking!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RewardsPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "gift.fill")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("No rewards available")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Level up to unlock amazing rewards!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Detail Views
struct BadgeDetailView: View {
    let badge: Badge
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Badge Icon
                Image(systemName: badge.iconName)
                    .font(.system(size: 80))
                    .foregroundColor(badge.isUnlocked ? rarityColor : .gray)
                    .opacity(badge.isUnlocked ? 1.0 : 0.4)
                
                VStack(spacing: 12) {
                    Text(badge.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(badge.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if badge.isUnlocked {
                        Text("Unlocked!")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(20)
                    } else {
                        VStack(spacing: 8) {
                            Text("Progress: \(Int(badge.progress))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: badge.progress, total: 100)
                                .tint(rarityColor)
                                .frame(maxWidth: 200)
                            
                            Text(badge.requirement)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Badge Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var rarityColor: Color {
        switch badge.rarity.color {
        case "gray": return .gray
        case "blue": return .blue
        case "purple": return .purple
        case "gold": return .yellow
        default: return .gray
        }
    }
}

struct ChallengeDetailView: View {
    let challenge: Challenge
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Challenge Header
                    VStack(spacing: 16) {
                        Image(systemName: challenge.type.icon)
                            .font(.system(size: 60))
                            .foregroundColor(getTypeColor(challenge.type))
                        
                        Text(challenge.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(challenge.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Progress Section
                    VStack(spacing: 16) {
                        Text("Progress")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Completed")
                                Spacer()
                                Text("\(Int(challenge.progress)) / \(Int(challenge.target)) \(challenge.type.unit)")
                            }
                            .font(.subheadline)
                            
                            ProgressView(value: challenge.progress, total: challenge.target)
                                .tint(getTypeColor(challenge.type))
                            
                            HStack {
                                Text("\(Int(challenge.progressPercentage))% Complete")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                if challenge.timeRemaining > 0 {
                                    Text(timeRemainingString(challenge.timeRemaining))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Expired")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    // Reward Section
                    VStack(spacing: 12) {
                        Text("Reward")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                            
                            Text("\(challenge.xpReward) XP")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            if challenge.isCompleted {
                                Text("Completed!")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getTypeColor(_ type: Challenge.ChallengeType) -> Color {
        switch type {
        case .steps: return .green
        case .exercise: return .blue
        case .fasting: return .orange
        case .hydration: return .cyan
        case .calories: return .red
        case .consistency: return .purple
        }
    }
    
    private func timeRemainingString(_ timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval / 86400)
        let hours = Int((timeInterval.truncatingRemainder(dividingBy: 86400)) / 3600)
        
        if days > 0 {
            return "\(days) days, \(hours) hours left"
        } else if hours > 0 {
            return "\(hours) hours left"
        } else {
            return "Less than 1 hour left"
        }
    }
}

struct RewardStoreView: View {
    let gamificationService: GamificationService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Points Balance
                    VStack(spacing: 12) {
                        Text("Your Points")
                            .font(.headline)
                        
                        Text("\(gamificationService.availablePoints)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Reward Categories
                    ForEach(Reward.RewardType.allCases, id: \.self) { type in
                        let rewards = gamificationService.rewards.filter { $0.type == type && $0.isUnlocked }
                        
                        if !rewards.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(type.category)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ForEach(rewards, id: \.id) { reward in
                                        RewardStoreCard(reward: reward, gamificationService: gamificationService)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Reward Store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RewardStoreCard: View {
    let reward: Reward
    let gamificationService: GamificationService
    @State private var isPurchasing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(reward.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Text(reward.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Text("\(reward.cost) points")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if reward.isPurchased {
                    Text("Owned")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                } else {
                    Button("Buy") {
                        isPurchasing = true
                        let success = gamificationService.purchaseReward(reward)
                        if success {
                            // Handle successful purchase
                        }
                        isPurchasing = false
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(canAfford ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .disabled(!canAfford || isPurchasing)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    private var canAfford: Bool {
        gamificationService.availablePoints >= reward.cost
    }
}

// MARK: - Extensions
extension Badge.BadgeCategory: CaseIterable {
    public static var allCases: [Badge.BadgeCategory] {
        return [.nutrition, .exercise, .hydration, .fasting, .consistency, .achievement, .social]
    }
}

extension Reward.RewardType: CaseIterable {
    public static var allCases: [Reward.RewardType] {
        return [.theme, .avatar, .title, .feature, .cosmetic]
    }
}

#Preview {
    GamificationView()
}