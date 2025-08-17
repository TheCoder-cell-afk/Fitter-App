import Foundation
import Combine

// MARK: - Gamification Models
struct UserLevel {
    let level: Int
    let title: String
    let xpRequired: Int
    let xpProgress: Int
    let benefits: [String]
    
    var progressPercentage: Double {
        return Double(xpProgress) / Double(xpRequired) * 100
    }
    
    var isMaxLevel: Bool {
        return level >= 100
    }
}

struct Badge: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let category: BadgeCategory
    let rarity: BadgeRarity
    let unlockedDate: Date?
    let progress: Double // 0-100
    let requirement: String
    
    var isUnlocked: Bool {
        return unlockedDate != nil
    }
    
    enum BadgeCategory {
        case nutrition, exercise, hydration, fasting, consistency, achievement, social
    }
    
    enum BadgeRarity {
        case common, rare, epic, legendary
        
        var color: String {
            switch self {
            case .common: return "gray"
            case .rare: return "blue"
            case .epic: return "purple"
            case .legendary: return "gold"
            }
        }
        
        var xpReward: Int {
            switch self {
            case .common: return 50
            case .rare: return 100
            case .epic: return 200
            case .legendary: return 500
            }
        }
    }
}

struct Streak {
    let type: StreakType
    let current: Int
    let best: Int
    let lastUpdated: Date
    let isActive: Bool
    
    enum StreakType {
        case dailyLogging, exercise, fasting, hydration, consistency
        
        var title: String {
            switch self {
            case .dailyLogging: return "Daily Logging"
            case .exercise: return "Exercise"
            case .fasting: return "Fasting"
            case .hydration: return "Hydration"
            case .consistency: return "Overall Consistency"
            }
        }
        
        var icon: String {
            switch self {
            case .dailyLogging: return "calendar.badge.plus"
            case .exercise: return "figure.run"
            case .fasting: return "clock.badge"
            case .hydration: return "drop.fill"
            case .consistency: return "star.fill"
            }
        }
    }
}

struct LeaderboardEntry {
    let userId: String
    let username: String
    let score: Int
    let rank: Int
    let category: LeaderboardCategory
    let badge: String?
    
    enum LeaderboardCategory {
        case overall, weekly, exercise, fasting, consistency
        
        var title: String {
            switch self {
            case .overall: return "Overall Score"
            case .weekly: return "This Week"
            case .exercise: return "Exercise Points"
            case .fasting: return "Fasting Master"
            case .consistency: return "Consistency Champion"
            }
        }
    }
}

struct Reward: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let type: RewardType
    let cost: Int
    let isUnlocked: Bool
    let isPurchased: Bool
    
    enum RewardType {
        case theme, avatar, title, feature, cosmetic
        
        var category: String {
            switch self {
            case .theme: return "App Themes"
            case .avatar: return "Profile Avatars"
            case .title: return "User Titles"
            case .feature: return "Premium Features"
            case .cosmetic: return "Cosmetics"
            }
        }
    }
}

struct Challenge: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let type: ChallengeType
    let duration: TimeInterval
    let target: Double
    let progress: Double
    let xpReward: Int
    let startDate: Date
    let endDate: Date
    let isActive: Bool
    let isCompleted: Bool
    
    var progressPercentage: Double {
        return min(100, (progress / target) * 100)
    }
    
    var timeRemaining: TimeInterval {
        return endDate.timeIntervalSince(Date())
    }
    
    enum ChallengeType {
        case steps, exercise, fasting, hydration, calories, consistency
        
        var icon: String {
            switch self {
            case .steps: return "figure.walk"
            case .exercise: return "figure.run"
            case .fasting: return "clock.badge"
            case .hydration: return "drop.fill"
            case .calories: return "flame.fill"
            case .consistency: return "checkmark.circle.fill"
            }
        }
        
        var unit: String {
            switch self {
            case .steps: return "steps"
            case .exercise: return "minutes"
            case .fasting: return "hours"
            case .hydration: return "L"
            case .calories: return "kcal"
            case .consistency: return "days"
            }
        }
    }
}

// MARK: - Gamification Service
class GamificationService: ObservableObject {
    @Published var userLevel: UserLevel = UserLevel(level: 1, title: "Beginner", xpRequired: 100, xpProgress: 0, benefits: [])
    @Published var totalXP: Int = 0
    @Published var availablePoints: Int = 0
    @Published var badges: [Badge] = []
    @Published var streaks: [Streak] = []
    @Published var challenges: [Challenge] = []
    @Published var rewards: [Reward] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var recentAchievements: [String] = []
    @Published var isLoading: Bool = true
    
    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private let totalXPKey = "GamificationTotalXP"
    private let availablePointsKey = "GamificationAvailablePoints"
    private let badgesKey = "GamificationBadges"
    private let streaksKey = "GamificationStreaks"
    private let challengesKey = "GamificationChallenges"
    private let rewardsKey = "GamificationRewards"
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        loadGamificationData()
        setupDataObservation()
        setupXPObservation()
        initializeBadges()
        initializeRewards()
        initializeChallenges()
        calculateCurrentStatus()
        
        // Set loading to false after initialization
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = false
        }
    }
    
    private func setupDataObservation() {
        // Update gamification when data changes
        dataManager.objectWillChange
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateProgress()
            }
            .store(in: &cancellables)
    }
    
    private func setupXPObservation() {
        // Listen for XP award notifications
        NotificationCenter.default.publisher(for: .init("AwardXP"))
            .sink { [weak self] notification in
                if let userInfo = notification.object as? [String: Any],
                   let amount = userInfo["amount"] as? Int,
                   let reason = userInfo["reason"] as? String {
                    DispatchQueue.main.async {
                        self?.awardXP(amount, for: reason)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Gamification Preference Check
    var isGamificationEnabled: Bool {
        return dataManager.userProfile?.gamificationEnabled ?? true
    }
    
    // MARK: - XP and Level System
    func awardXP(_ amount: Int, for reason: String) {
        // Only award XP if gamification is enabled
        guard isGamificationEnabled else { return }
        
        totalXP += amount
        availablePoints += amount
        
        checkLevelUp()
        addRecentAchievement("Earned \(amount) XP for \(reason)")
        saveGamificationData()
        
        // Trigger haptic feedback for XP gain
        generateHapticFeedback()
    }
    
    private func checkLevelUp() {
        let newLevel = calculateLevel(for: totalXP)
        if newLevel > userLevel.level {
            levelUp(to: newLevel)
        }
        
        let currentLevelXP = getXPRequired(for: newLevel)
        let xpProgress = max(0, totalXP - currentLevelXP) // Ensure progress is never negative
        
        userLevel = UserLevel(
            level: newLevel,
            title: getLevelTitle(for: newLevel),
            xpRequired: getXPRequired(for: newLevel + 1),
            xpProgress: xpProgress,
            benefits: getLevelBenefits(for: newLevel)
        )
    }
    
    private func levelUp(to level: Int) {
        let title = getLevelTitle(for: level)
        addRecentAchievement("🎉 Level Up! You're now \(title) (Level \(level))")
        
        // Award bonus XP for leveling up
        let bonusXP = level * 10
        totalXP += bonusXP
        availablePoints += bonusXP
        
        // Unlock level-based rewards
        unlockLevelRewards(for: level)
        
        // Generate special haptic for level up
        generateCelebrationHaptic()
    }
    
    private func calculateLevel(for xp: Int) -> Int {
        // Exponential leveling: Level = sqrt(XP / 100)
        return max(1, Int(sqrt(Double(xp) / 100.0)))
    }
    
    private func getXPRequired(for level: Int) -> Int {
        // XP required for level = level^2 * 100
        return level * level * 100
    }
    
    private func getLevelTitle(for level: Int) -> String {
        switch level {
        case 1...5: return "Beginner"
        case 6...10: return "Novice"
        case 11...15: return "Amateur"
        case 16...25: return "Enthusiast"
        case 26...35: return "Expert"
        case 36...50: return "Master"
        case 51...70: return "Champion"
        case 71...90: return "Legend"
        case 91...99: return "Grandmaster"
        case 100...: return "Wellness Guru"
        default: return "Beginner"
        }
    }
    
    private func getLevelBenefits(for level: Int) -> [String] {
        var benefits: [String] = []
        
        if level >= 5 { benefits.append("Custom app themes") }
        if level >= 10 { benefits.append("Advanced analytics") }
        if level >= 15 { benefits.append("Premium challenges") }
        if level >= 20 { benefits.append("Social features") }
        if level >= 25 { benefits.append("Personal trainer AI") }
        if level >= 30 { benefits.append("Nutrition coach AI") }
        if level >= 50 { benefits.append("Exclusive badges") }
        if level >= 75 { benefits.append("VIP support") }
        if level >= 100 { benefits.append("Guru status + all perks") }
        
        return benefits
    }
    
    // MARK: - Badge System
    private func initializeBadges() {
        badges = createAllBadges()
        updateBadgeProgress()
    }
    
    private func createAllBadges() -> [Badge] {
        return [
            // Nutrition Badges
            Badge(name: "First Meal", description: "Log your first meal", iconName: "fork.knife", category: .nutrition, rarity: .common, unlockedDate: nil, progress: 0, requirement: "Log 1 meal"),
            Badge(name: "Calorie Counter", description: "Log 50 meals", iconName: "chart.bar.fill", category: .nutrition, rarity: .rare, unlockedDate: nil, progress: 0, requirement: "Log 50 meals"),
            Badge(name: "Macro Master", description: "Hit all macro targets for 7 days", iconName: "target", category: .nutrition, rarity: .epic, unlockedDate: nil, progress: 0, requirement: "Perfect macros for 7 days"),
            Badge(name: "Nutrition Guru", description: "Log 365 days of meals", iconName: "brain.head.profile", category: .nutrition, rarity: .legendary, unlockedDate: nil, progress: 0, requirement: "Log meals for 365 days"),
            
            // Exercise Badges
            Badge(name: "First Workout", description: "Complete your first exercise", iconName: "figure.run", category: .exercise, rarity: .common, unlockedDate: nil, progress: 0, requirement: "Complete 1 exercise"),
            Badge(name: "Consistency King", description: "Exercise 5 days in a row", iconName: "calendar.badge.checkmark", category: .exercise, rarity: .rare, unlockedDate: nil, progress: 0, requirement: "Exercise 5 consecutive days"),
            Badge(name: "Iron Will", description: "Exercise 30 days in a row", iconName: "flame.fill", category: .exercise, rarity: .epic, unlockedDate: nil, progress: 0, requirement: "Exercise 30 consecutive days"),
            Badge(name: "Fitness Legend", description: "Complete 1000 workouts", iconName: "crown.fill", category: .exercise, rarity: .legendary, unlockedDate: nil, progress: 0, requirement: "Complete 1000 workouts"),
            
            // Hydration Badges
            Badge(name: "First Drop", description: "Log your first water intake", iconName: "drop.fill", category: .hydration, rarity: .common, unlockedDate: nil, progress: 0, requirement: "Log first water"),
            Badge(name: "Hydration Hero", description: "Meet daily water goal for 7 days", iconName: "drop.circle.fill", category: .hydration, rarity: .rare, unlockedDate: nil, progress: 0, requirement: "Meet water goal 7 days"),
            Badge(name: "Ocean Master", description: "Drink 1000L of water total", iconName: "water.waves", category: .hydration, rarity: .epic, unlockedDate: nil, progress: 0, requirement: "Drink 1000L total"),
            
            // Fasting Badges
            Badge(name: "Fasting Novice", description: "Complete your first fast", iconName: "clock.badge", category: .fasting, rarity: .common, unlockedDate: nil, progress: 0, requirement: "Complete 1 fast"),
            Badge(name: "Intermittent Expert", description: "Complete 50 fasts", iconName: "clock.circle.fill", category: .fasting, rarity: .rare, unlockedDate: nil, progress: 0, requirement: "Complete 50 fasts"),
            Badge(name: "Fasting Master", description: "Complete a 24-hour fast", iconName: "moon.stars.fill", category: .fasting, rarity: .epic, unlockedDate: nil, progress: 0, requirement: "Complete 24-hour fast"),
            Badge(name: "Zen Master", description: "Complete 365 fasts", iconName: "brain.head.profile", category: .fasting, rarity: .legendary, unlockedDate: nil, progress: 0, requirement: "Complete 365 fasts"),
            
            // Consistency Badges
            Badge(name: "Dedicated", description: "Use app for 7 consecutive days", iconName: "checkmark.circle.fill", category: .consistency, rarity: .common, unlockedDate: nil, progress: 0, requirement: "Use app 7 consecutive days"),
            Badge(name: "Committed", description: "Use app for 30 consecutive days", iconName: "star.circle.fill", category: .consistency, rarity: .rare, unlockedDate: nil, progress: 0, requirement: "Use app 30 consecutive days"),
            Badge(name: "Unstoppable", description: "Use app for 100 consecutive days", iconName: "bolt.circle.fill", category: .consistency, rarity: .epic, unlockedDate: nil, progress: 0, requirement: "Use app 100 consecutive days"),
            Badge(name: "Lifestyle", description: "Use app for 365 consecutive days", iconName: "infinity.circle.fill", category: .consistency, rarity: .legendary, unlockedDate: nil, progress: 0, requirement: "Use app 365 consecutive days"),
            
            // Achievement Badges
            Badge(name: "Goal Crusher", description: "Complete your first challenge", iconName: "trophy.fill", category: .achievement, rarity: .common, unlockedDate: nil, progress: 0, requirement: "Complete 1 challenge"),
            Badge(name: "Overachiever", description: "Complete 10 challenges", iconName: "rosette", category: .achievement, rarity: .rare, unlockedDate: nil, progress: 0, requirement: "Complete 10 challenges"),
            Badge(name: "Champion", description: "Reach level 50", iconName: "medal.fill", category: .achievement, rarity: .epic, unlockedDate: nil, progress: 0, requirement: "Reach level 50"),
            Badge(name: "Wellness Master", description: "Achieve 90+ health score for 30 days", iconName: "heart.circle.fill", category: .achievement, rarity: .legendary, unlockedDate: nil, progress: 0, requirement: "90+ health score for 30 days")
        ]
    }
    
    private func updateBadgeProgress() {
        for i in 0..<badges.count {
            badges[i] = calculateBadgeProgress(badge: badges[i])
        }
    }
    
    private func calculateBadgeProgress(badge: Badge) -> Badge {
        var progress: Double = 0
        var unlockedDate: Date? = badge.unlockedDate
        
        switch badge.name {
        case "First Meal":
            progress = dataManager.foodEntries.isEmpty ? 0 : 100
        case "Calorie Counter":
            progress = min(100, Double(dataManager.foodEntries.count) / 50 * 100)
        case "First Workout":
            progress = dataManager.exercises.isEmpty ? 0 : 100
        case "First Drop":
            progress = WaterTrackerService.shared.waterEntries.isEmpty ? 0 : 100
        case "Fasting Novice":
            let completedFasts = dataManager.fastingSessions.filter { $0.endTime != nil }.count
            progress = completedFasts > 0 ? 100 : 0
        case "Intermittent Expert":
            let completedFasts = dataManager.fastingSessions.filter { $0.endTime != nil }.count
            progress = min(100, Double(completedFasts) / 50 * 100)
        case "Dedicated":
            progress = calculateConsecutiveDaysProgress(target: 7)
        case "Committed":
            progress = calculateConsecutiveDaysProgress(target: 30)
        case "Goal Crusher":
            let completedChallenges = challenges.filter { $0.isCompleted }.count
            progress = completedChallenges > 0 ? 100 : 0
        default:
            // More complex calculations for other badges
            progress = badge.progress
        }
        
        // Check if badge should be unlocked
        if progress >= 100 && badge.unlockedDate == nil {
            unlockedDate = Date()
            awardXP(badge.rarity.xpReward, for: "unlocking \(badge.name)")
            addRecentAchievement("🏆 Badge Unlocked: \(badge.name)")
        }
        
        return Badge(
            name: badge.name,
            description: badge.description,
            iconName: badge.iconName,
            category: badge.category,
            rarity: badge.rarity,
            unlockedDate: unlockedDate,
            progress: progress,
            requirement: badge.requirement
        )
    }
    
    private func calculateConsecutiveDaysProgress(target: Int) -> Double {
        // Calculate consecutive days of app usage
        let calendar = Calendar.current
        var consecutiveDays = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for _ in 0..<target {
            let hasActivity = !dataManager.foodEntries.filter { 
                calendar.isDate($0.date, inSameDayAs: currentDate) 
            }.isEmpty ||
            !dataManager.exercises.filter { 
                calendar.isDate($0.date, inSameDayAs: currentDate) 
            }.isEmpty ||
            !WaterTrackerService.shared.waterEntries.filter { 
                calendar.isDate($0.timestamp, inSameDayAs: currentDate) 
            }.isEmpty
            
            if hasActivity {
                consecutiveDays += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return min(100, Double(consecutiveDays) / Double(target) * 100)
    }
    
    // MARK: - Streak System
    private func updateStreaks() {
        streaks = [
            calculateDailyLoggingStreak(),
            calculateExerciseStreak(),
            calculateFastingStreak(),
            calculateHydrationStreak(),
            calculateConsistencyStreak()
        ]
    }
    
    private func calculateDailyLoggingStreak() -> Streak {
        let calendar = Calendar.current
        var currentStreak = 0
        var bestStreak = userDefaults.integer(forKey: "BestDailyLoggingStreak")
        var currentDate = calendar.startOfDay(for: Date())
        
        // Check consecutive days with any logging activity
        for _ in 0..<365 { // Check up to a year
            let hasActivity = !dataManager.foodEntries.filter { 
                calendar.isDate($0.date, inSameDayAs: currentDate) 
            }.isEmpty ||
            !dataManager.exercises.filter { 
                calendar.isDate($0.date, inSameDayAs: currentDate) 
            }.isEmpty ||
            !WaterTrackerService.shared.waterEntries.filter { 
                calendar.isDate($0.timestamp, inSameDayAs: currentDate) 
            }.isEmpty
            
            if hasActivity {
                currentStreak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        bestStreak = max(bestStreak, currentStreak)
        userDefaults.set(bestStreak, forKey: "BestDailyLoggingStreak")
        
        return Streak(
            type: .dailyLogging,
            current: currentStreak,
            best: bestStreak,
            lastUpdated: Date(),
            isActive: currentStreak > 0
        )
    }
    
    private func calculateExerciseStreak() -> Streak {
        let exerciseDays = Set(dataManager.exercises.map { 
            Calendar.current.startOfDay(for: $0.date) 
        }).sorted(by: >)
        
        var currentStreak = 0
        var bestStreak = userDefaults.integer(forKey: "BestExerciseStreak")
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        
        for _ in 0..<exerciseDays.count {
            if exerciseDays.contains(currentDate) {
                currentStreak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        bestStreak = max(bestStreak, currentStreak)
        userDefaults.set(bestStreak, forKey: "BestExerciseStreak")
        
        return Streak(
            type: .exercise,
            current: currentStreak,
            best: bestStreak,
            lastUpdated: Date(),
            isActive: currentStreak > 0
        )
    }
    
    private func calculateFastingStreak() -> Streak {
        let completedFasts = dataManager.fastingSessions
            .filter { $0.endTime != nil }
            .sorted { $0.startTime > $1.startTime }
        
        var currentStreak = 0
        var bestStreak = userDefaults.integer(forKey: "BestFastingStreak")
        let calendar = Calendar.current
        
        var lastFastDate: Date?
        for fastingSession in completedFasts {
            let fastDate = calendar.startOfDay(for: fastingSession.startTime)
            
            if let lastDate = lastFastDate {
                let daysDifference = calendar.dateComponents([.day], from: fastDate, to: lastDate).day ?? 0
                if daysDifference <= 2 { // Allow 1 day gap between fasts
                    currentStreak += 1
                } else {
                    break
                }
            } else {
                currentStreak = 1
            }
            
            lastFastDate = fastDate
        }
        
        bestStreak = max(bestStreak, currentStreak)
        userDefaults.set(bestStreak, forKey: "BestFastingStreak")
        
        return Streak(
            type: .fasting,
            current: currentStreak,
            best: bestStreak,
            lastUpdated: Date(),
            isActive: currentStreak > 0
        )
    }
    
    private func calculateHydrationStreak() -> Streak {
        let calendar = Calendar.current
        var currentStreak = 0
        var bestStreak = userDefaults.integer(forKey: "BestHydrationStreak")
        var currentDate = calendar.startOfDay(for: Date())
        let dailyGoal = dataManager.calculateDailyWaterGoal()
        
        for _ in 0..<365 {
            let dayWater = WaterTrackerService.shared.waterEntries
                .filter { calendar.isDate($0.timestamp, inSameDayAs: currentDate) }
                .reduce(0) { $0 + $1.amount }
            
            if dayWater >= dailyGoal {
                currentStreak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        bestStreak = max(bestStreak, currentStreak)
        userDefaults.set(bestStreak, forKey: "BestHydrationStreak")
        
        return Streak(
            type: .hydration,
            current: currentStreak,
            best: bestStreak,
            lastUpdated: Date(),
            isActive: currentStreak > 0
        )
    }
    
    private func calculateConsistencyStreak() -> Streak {
        // Consistency means meeting at least 3 out of 4 daily goals
        let calendar = Calendar.current
        var currentStreak = 0
        var bestStreak = userDefaults.integer(forKey: "BestConsistencyStreak")
        var currentDate = calendar.startOfDay(for: Date())
        
        for _ in 0..<365 {
            var goalsHit = 0
            
            // Check nutrition goal
            let dayFoods = dataManager.foodEntries.filter { calendar.isDate($0.date, inSameDayAs: currentDate) }
            if !dayFoods.isEmpty { goalsHit += 1 }
            
            // Check exercise goal
            let dayExercises = dataManager.exercises.filter { calendar.isDate($0.date, inSameDayAs: currentDate) }
            if !dayExercises.isEmpty { goalsHit += 1 }
            
            // Check hydration goal
            let dayWater = WaterTrackerService.shared.waterEntries
                .filter { calendar.isDate($0.timestamp, inSameDayAs: currentDate) }
                .reduce(0) { $0 + $1.amount }
            let dailyGoal = dataManager.calculateDailyWaterGoal()
            if dayWater >= dailyGoal * 0.8 { goalsHit += 1 } // 80% is good enough
            
            // Check fasting goal (if there's an active session)
            let dayFasts = dataManager.fastingSessions.filter { 
                calendar.isDate($0.startTime, inSameDayAs: currentDate) 
            }
            if !dayFasts.isEmpty { goalsHit += 1 }
            
            if goalsHit >= 3 {
                currentStreak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        bestStreak = max(bestStreak, currentStreak)
        userDefaults.set(bestStreak, forKey: "BestConsistencyStreak")
        
        return Streak(
            type: .consistency,
            current: currentStreak,
            best: bestStreak,
            lastUpdated: Date(),
            isActive: currentStreak > 0
        )
    }
    
    // MARK: - Challenge System
    private func initializeChallenges() {
        challenges = createActiveChallenges()
    }
    
    private func createActiveChallenges() -> [Challenge] {
        let now = Date()
        let calendar = Calendar.current
        
        return [
            // Weekly challenges
            Challenge(
                name: "Exercise Marathon",
                description: "Exercise 5 times this week",
                type: .exercise,
                duration: 7 * 24 * 3600, // 7 days
                target: 5,
                progress: 0,
                xpReward: 200,
                startDate: calendar.startOfDay(for: now),
                endDate: calendar.date(byAdding: .weekOfYear, value: 1, to: calendar.startOfDay(for: now)) ?? now,
                isActive: true,
                isCompleted: false
            ),
            Challenge(
                name: "Hydration Hero",
                description: "Drink 2L of water every day this week",
                type: .hydration,
                duration: 7 * 24 * 3600,
                target: 7,
                progress: 0,
                xpReward: 150,
                startDate: calendar.startOfDay(for: now),
                endDate: calendar.date(byAdding: .weekOfYear, value: 1, to: calendar.startOfDay(for: now)) ?? now,
                isActive: true,
                isCompleted: false
            ),
            Challenge(
                name: "Fasting Warrior",
                description: "Complete 3 fasts of 16+ hours",
                type: .fasting,
                duration: 7 * 24 * 3600,
                target: 3,
                progress: 0,
                xpReward: 250,
                startDate: calendar.startOfDay(for: now),
                endDate: calendar.date(byAdding: .weekOfYear, value: 1, to: calendar.startOfDay(for: now)) ?? now,
                isActive: true,
                isCompleted: false
            ),
            Challenge(
                name: "Consistency King",
                description: "Log something every day for 7 days",
                type: .consistency,
                duration: 7 * 24 * 3600,
                target: 7,
                progress: 0,
                xpReward: 300,
                startDate: calendar.startOfDay(for: now),
                endDate: calendar.date(byAdding: .weekOfYear, value: 1, to: calendar.startOfDay(for: now)) ?? now,
                isActive: true,
                isCompleted: false
            )
        ]
    }
    
    private func updateChallengeProgress() {
        for i in 0..<challenges.count {
            challenges[i] = calculateChallengeProgress(challenge: challenges[i])
        }
    }
    
    private func calculateChallengeProgress(challenge: Challenge) -> Challenge {
        let calendar = Calendar.current
        var progress = challenge.progress
        
        switch challenge.type {
        case .exercise:
            let exerciseDays = Set(dataManager.exercises
                .filter { $0.date >= challenge.startDate && $0.date <= challenge.endDate }
                .map { calendar.startOfDay(for: $0.date) }
            ).count
            progress = Double(exerciseDays)
            
        case .hydration:
            var daysWithGoal = 0
            let dailyGoal = dataManager.calculateDailyWaterGoal()
            
            var currentDate = challenge.startDate
            while currentDate <= min(challenge.endDate, Date()) {
                let dayWater = WaterTrackerService.shared.waterEntries
                    .filter { calendar.isDate($0.timestamp, inSameDayAs: currentDate) }
                    .reduce(0) { $0 + $1.amount }
                
                if dayWater >= dailyGoal {
                    daysWithGoal += 1
                }
                
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            progress = Double(daysWithGoal)
            
        case .fasting:
            let completedFasts = dataManager.fastingSessions
                .filter { session in
                    guard let endTime = session.endTime else { return false }
                    let duration = endTime.timeIntervalSince(session.startTime) / 3600 // hours
                    return duration >= 16 && 
                           session.startTime >= challenge.startDate && 
                           session.startTime <= challenge.endDate
                }
            progress = Double(completedFasts.count)
            
        case .consistency:
            var consistentDays = 0
            var currentDate = challenge.startDate
            
            while currentDate <= min(challenge.endDate, Date()) {
                let hasActivity = !dataManager.foodEntries.filter { 
                    calendar.isDate($0.date, inSameDayAs: currentDate) 
                }.isEmpty ||
                !dataManager.exercises.filter { 
                    calendar.isDate($0.date, inSameDayAs: currentDate) 
                }.isEmpty ||
                !WaterTrackerService.shared.waterEntries.filter { 
                    calendar.isDate($0.timestamp, inSameDayAs: currentDate) 
                }.isEmpty
                
                if hasActivity {
                    consistentDays += 1
                }
                
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            progress = Double(consistentDays)
            
        default:
            break
        }
        
        let isCompleted = progress >= challenge.target
        if isCompleted && !challenge.isCompleted {
            awardXP(challenge.xpReward, for: "completing \(challenge.name)")
            addRecentAchievement("🏆 Challenge Complete: \(challenge.name)")
        }
        
        return Challenge(
            name: challenge.name,
            description: challenge.description,
            type: challenge.type,
            duration: challenge.duration,
            target: challenge.target,
            progress: progress,
            xpReward: challenge.xpReward,
            startDate: challenge.startDate,
            endDate: challenge.endDate,
            isActive: challenge.isActive && Date() <= challenge.endDate,
            isCompleted: isCompleted
        )
    }
    
    // MARK: - Reward System
    private func initializeRewards() {
        rewards = createAllRewards()
    }
    
    private func createAllRewards() -> [Reward] {
        return [
            // Themes
            Reward(name: "Dark Ocean", description: "Deep blue ocean theme", type: .theme, cost: 100, isUnlocked: userLevel.level >= 5, isPurchased: false),
            Reward(name: "Forest Green", description: "Natural forest theme", type: .theme, cost: 150, isUnlocked: userLevel.level >= 10, isPurchased: false),
            Reward(name: "Sunset Orange", description: "Warm sunset theme", type: .theme, cost: 200, isUnlocked: userLevel.level >= 15, isPurchased: false),
            Reward(name: "Royal Purple", description: "Elegant purple theme", type: .theme, cost: 300, isUnlocked: userLevel.level >= 25, isPurchased: false),
            
            // Avatars
            Reward(name: "Fitness Warrior", description: "Strong warrior avatar", type: .avatar, cost: 75, isUnlocked: userLevel.level >= 5, isPurchased: false),
            Reward(name: "Zen Master", description: "Peaceful meditation avatar", type: .avatar, cost: 100, isUnlocked: userLevel.level >= 10, isPurchased: false),
            Reward(name: "Health Guru", description: "Wise health expert avatar", type: .avatar, cost: 150, isUnlocked: userLevel.level >= 20, isPurchased: false),
            
            // Titles
            Reward(name: "Health Enthusiast", description: "Show your passion for health", type: .title, cost: 50, isUnlocked: userLevel.level >= 3, isPurchased: false),
            Reward(name: "Wellness Champion", description: "Champion of wellness", type: .title, cost: 200, isUnlocked: userLevel.level >= 30, isPurchased: false),
            Reward(name: "Fitness Legend", description: "Legendary fitness status", type: .title, cost: 500, isUnlocked: userLevel.level >= 50, isPurchased: false),
            
            // Features
            Reward(name: "Advanced Analytics", description: "Unlock premium analytics", type: .feature, cost: 300, isUnlocked: userLevel.level >= 15, isPurchased: false),
            Reward(name: "Personal AI Coach", description: "24/7 AI health coaching", type: .feature, cost: 500, isUnlocked: userLevel.level >= 25, isPurchased: false),
            Reward(name: "Social Challenges", description: "Create challenges with friends", type: .feature, cost: 250, isUnlocked: userLevel.level >= 20, isPurchased: false)
        ]
    }
    
    func purchaseReward(_ reward: Reward) -> Bool {
        guard reward.isUnlocked && !reward.isPurchased && availablePoints >= reward.cost else {
            return false
        }
        
        availablePoints -= reward.cost
        
        // Update the reward as purchased
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            rewards[index] = Reward(
                name: reward.name,
                description: reward.description,
                type: reward.type,
                cost: reward.cost,
                isUnlocked: reward.isUnlocked,
                isPurchased: true
            )
        }
        
        addRecentAchievement("🛍️ Purchased: \(reward.name)")
        saveGamificationData()
        return true
    }
    
    private func unlockLevelRewards(for level: Int) {
        for i in 0..<rewards.count {
            if !rewards[i].isUnlocked && 
               ((level >= 5 && rewards[i].type == .theme) ||
                (level >= 10 && rewards[i].name == "Forest Green") ||
                (level >= 15 && rewards[i].name == "Advanced Analytics")) {
                rewards[i] = Reward(
                    name: rewards[i].name,
                    description: rewards[i].description,
                    type: rewards[i].type,
                    cost: rewards[i].cost,
                    isUnlocked: true,
                    isPurchased: rewards[i].isPurchased
                )
                addRecentAchievement("🔓 Unlocked: \(rewards[i].name)")
            }
        }
    }
    
    // MARK: - Social Features (Mock Implementation)
    private func updateLeaderboard() {
        // Mock leaderboard data
        leaderboard = [
            LeaderboardEntry(userId: "user1", username: "HealthGuru", score: 2450, rank: 1, category: .overall, badge: "👑"),
            LeaderboardEntry(userId: "user2", username: "FitnessPro", score: 2380, rank: 2, category: .overall, badge: "🥈"),
            LeaderboardEntry(userId: "user3", username: "WellnessWiz", score: 2320, rank: 3, category: .overall, badge: "🥉"),
            LeaderboardEntry(userId: "current", username: "You", score: totalXP, rank: 4, category: .overall, badge: nil),
            LeaderboardEntry(userId: "user4", username: "HealthHero", score: 1890, rank: 5, category: .overall, badge: nil),
        ].sorted { $0.score > $1.score }
        
        // Update ranks
        for i in 0..<leaderboard.count {
            leaderboard[i] = LeaderboardEntry(
                userId: leaderboard[i].userId,
                username: leaderboard[i].username,
                score: leaderboard[i].score,
                rank: i + 1,
                category: leaderboard[i].category,
                badge: leaderboard[i].badge
            )
        }
    }
    
    // MARK: - Progress Updates
    func updateProgress() {
        updateBadgeProgress()
        updateStreaks()
        updateChallengeProgress()
        updateLeaderboard()
        saveGamificationData()
    }
    
    private func calculateCurrentStatus() {
        updateProgress()
    }
    
    // MARK: - Utilities
    private func addRecentAchievement(_ achievement: String) {
        recentAchievements.insert(achievement, at: 0)
        if recentAchievements.count > 10 {
            recentAchievements = Array(recentAchievements.prefix(10))
        }
    }
    
    private func generateHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func generateCelebrationHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impactFeedback.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            impactFeedback.impactOccurred()
        }
    }
    
    // MARK: - Data Persistence
    private func saveGamificationData() {
        userDefaults.set(totalXP, forKey: totalXPKey)
        userDefaults.set(availablePoints, forKey: availablePointsKey)
        
        // Save badges, streaks, challenges, and rewards
        // For simplicity, we'll use the existing logic and recalculate on load
    }
    
    private func loadGamificationData() {
        totalXP = userDefaults.integer(forKey: totalXPKey)
        availablePoints = userDefaults.integer(forKey: availablePointsKey)
        
        // Give new users some starting XP if they have none
        if totalXP == 0 && userDefaults.object(forKey: totalXPKey) == nil {
            totalXP = 50 // Starting XP for new users
            availablePoints = 50
            userDefaults.set(totalXP, forKey: totalXPKey)
            userDefaults.set(availablePoints, forKey: availablePointsKey)
        }
        
        // Recalculate level based on XP
        checkLevelUp()
    }
    
    // MARK: - Public Interface
    func getDailyXPGoal() -> Int {
        return userLevel.level * 20 // Adaptive daily XP goal
    }
    
    func getTodayXP() -> Int {
        // Calculate XP earned today (simplified)
        return totalXP // This would be today's XP in a real implementation
    }
    
    func getNextLevelProgress() -> Double {
        let currentLevelXP = getXPRequired(for: userLevel.level)
        let nextLevelXP = getXPRequired(for: userLevel.level + 1)
        let progressXP = max(0, totalXP - currentLevelXP) // Ensure progress is never negative
        let requiredXP = nextLevelXP - currentLevelXP
        
        return min(100.0, max(0.0, Double(progressXP) / Double(requiredXP) * 100))
    }
}

import UIKit