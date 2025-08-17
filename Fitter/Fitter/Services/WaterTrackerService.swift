import Foundation

class WaterTrackerService: ObservableObject {
    static let shared = WaterTrackerService()
    
    @Published var waterEntries: [WaterEntry] = []
    @Published var dailyGoal: Double = 2000 // ml
    @Published var reminderEnabled: Bool = true
    @Published var reminderInterval: Int = 60 // minutes
    
    private init() {
        loadData()
        calculateDailyGoal()
    }
    
    // MARK: - Water Entry Management
    func addWaterEntry(amount: Double, timestamp: Date = Date()) {
        let entry = WaterEntry(amount: amount, timestamp: timestamp)
        waterEntries.append(entry)
        saveData()
        
        // Check for achievements
        checkWaterAchievements()
        
        // Award XP for drinking water
        let xpAmount = Int(amount / 250) * 5 // 5 XP per 250ml
        NotificationCenter.default.post(name: .init("AwardXP"), object: ["amount": max(2, xpAmount), "reason": "drinking \(Int(amount))ml of water"])
    }
    
    func removeWaterEntry(_ entry: WaterEntry) {
        waterEntries.removeAll { $0.id == entry.id }
        saveData()
    }
    
    func getTodayWaterIntake() -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return waterEntries
            .filter { $0.timestamp >= today && $0.timestamp < tomorrow }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getTodayEntries() -> [WaterEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return waterEntries
            .filter { $0.timestamp >= today && $0.timestamp < tomorrow }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    func getWeeklyProgress() -> [DailyWaterProgress] {
        let calendar = Calendar.current
        let today = Date()
        var weeklyData: [DailyWaterProgress] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let dailyIntake = waterEntries
                .filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
                .reduce(0) { $0 + $1.amount }
            
            weeklyData.append(DailyWaterProgress(
                date: date,
                intake: dailyIntake,
                goal: dailyGoal
            ))
        }
        
        return weeklyData.reversed()
    }
    
    // MARK: - Goal Calculation
    func calculateDailyGoal(weight: Double? = nil, activityLevel: ActivityLevel? = nil, climate: ClimateCondition = .moderate) {
        // Base calculation: 35ml per kg of body weight
        let baseAmount: Double
        
        if let weight = weight {
            baseAmount = weight * 35 // ml per kg
        } else {
            // Default for average adult
            baseAmount = 2000
        }
        
        // Activity adjustment
        var adjustedAmount = baseAmount
        if let activity = activityLevel {
            switch activity {
            case .sedentary:
                adjustedAmount *= 1.0
            case .lightlyActive:
                adjustedAmount *= 1.1
            case .moderatelyActive:
                adjustedAmount *= 1.2
            case .veryActive:
                adjustedAmount *= 1.4
            case .extremelyActive:
                adjustedAmount *= 1.6
            }
        }
        
        // Climate adjustment
        switch climate {
        case .cold:
            adjustedAmount *= 0.9
        case .moderate:
            adjustedAmount *= 1.0
        case .hot:
            adjustedAmount *= 1.3
        case .veryHot:
            adjustedAmount *= 1.5
        }
        
        // Round to nearest 250ml
        dailyGoal = (adjustedAmount / 250).rounded() * 250
        saveData()
    }
    
    func updateDailyGoal(_ newGoal: Double) {
        dailyGoal = max(500, min(5000, newGoal)) // Reasonable limits
        saveData()
    }
    
    // MARK: - Progress Calculations
    func getTodayProgress() -> Double {
        let today = getTodayWaterIntake()
        return min(today / dailyGoal, 1.0)
    }
    
    func getRemainingIntake() -> Double {
        let today = getTodayWaterIntake()
        return max(dailyGoal - today, 0)
    }
    
    func getProgressMessage() -> String {
        let progress = getTodayProgress()
        let remaining = getRemainingIntake()
        
        switch progress {
        case 0..<0.25:
            return "💧 Let's start hydrating! You have \(Int(remaining))ml to go."
        case 0.25..<0.5:
            return "🌊 Good start! Keep drinking, \(Int(remaining))ml remaining."
        case 0.5..<0.75:
            return "💙 Halfway there! \(Int(remaining))ml left to reach your goal."
        case 0.75..<1.0:
            return "🎯 Almost there! Just \(Int(remaining))ml more to go!"
        case 1.0...:
            return "🎉 Goal achieved! Great hydration today!"
        default:
            return "Stay hydrated!"
        }
    }
    
    // MARK: - Achievements
    private func checkWaterAchievements() {
        let todayIntake = getTodayWaterIntake()
        let progress = getTodayProgress()
        
        // Daily goal achievement
        if progress >= 1.0 {
            // Trigger achievement notification
            NotificationCenter.default.post(
                name: .init("WaterGoalAchieved"),
                object: nil,
                userInfo: ["intake": todayIntake, "goal": dailyGoal]
            )
        }
        
        // Milestone achievements
        let milestones = [500, 1000, 1500, 2000, 2500, 3000]
        for milestone in milestones {
            if todayIntake >= Double(milestone) {
                // Could trigger milestone achievements here
            }
        }
    }
    
    // MARK: - Recommendations
    func getHydrationTips() -> [String] {
        let currentHour = Calendar.current.component(.hour, from: Date())
        let progress = getTodayProgress()
        
        var tips: [String] = []
        
        // Time-based tips
        switch currentHour {
        case 6...9:
            tips.append("🌅 Start your day with 500ml of water to kickstart your metabolism")
        case 10...12:
            tips.append("☕ If you're having coffee, drink an extra glass of water")
        case 13...15:
            tips.append("🍽️ Drink water before and after meals to aid digestion")
        case 16...18:
            tips.append("🏃‍♂️ Pre-hydrate before any physical activity")
        case 19...21:
            tips.append("🌙 Wind down with herbal tea or warm water")
        default:
            tips.append("💧 Consistent hydration throughout the day is key")
        }
        
        // Progress-based tips
        if progress < 0.3 {
            tips.append("📱 Set hourly reminders to drink water")
            tips.append("🥤 Keep a water bottle visible as a reminder")
        } else if progress > 1.2 {
            tips.append("⚖️ Great hydration! Monitor your electrolyte balance")
        }
        
        // General tips
        tips.append("🍋 Add lemon or cucumber for flavor variety")
        tips.append("🧊 Room temperature water is absorbed faster than cold")
        tips.append("💪 Proper hydration improves physical performance")
        tips.append("🧠 Even mild dehydration can affect concentration")
        
        return tips.shuffled().prefix(3).map { $0 }
    }
    
    // MARK: - Data Persistence
    private func saveData() {
        let encoder = JSONEncoder()
        
        if let entriesData = try? encoder.encode(waterEntries) {
            UserDefaults.standard.set(entriesData, forKey: "waterEntries")
        }
        
        UserDefaults.standard.set(dailyGoal, forKey: "waterDailyGoal")
        UserDefaults.standard.set(reminderEnabled, forKey: "waterReminderEnabled")
        UserDefaults.standard.set(reminderInterval, forKey: "waterReminderInterval")
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        
        if let entriesData = UserDefaults.standard.data(forKey: "waterEntries"),
           let entries = try? decoder.decode([WaterEntry].self, from: entriesData) {
            waterEntries = entries
        }
        
        dailyGoal = UserDefaults.standard.double(forKey: "waterDailyGoal")
        if dailyGoal == 0 { dailyGoal = 2000 }
        
        reminderEnabled = UserDefaults.standard.bool(forKey: "waterReminderEnabled")
        reminderInterval = UserDefaults.standard.integer(forKey: "waterReminderInterval")
        if reminderInterval == 0 { reminderInterval = 60 }
    }
}

// MARK: - Data Models
struct WaterEntry: Identifiable, Codable {
    let id: UUID
    let amount: Double // in ml
    let timestamp: Date
    
    init(amount: Double, timestamp: Date = Date()) {
        self.id = UUID()
        self.amount = amount
        self.timestamp = timestamp
    }
    
    var formattedAmount: String {
        if amount >= 1000 {
            return String(format: "%.1fL", amount / 1000)
        } else {
            return "\(Int(amount))ml"
        }
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

struct DailyWaterProgress {
    let date: Date
    let intake: Double
    let goal: Double
    
    var progress: Double {
        return min(intake / goal, 1.0)
    }
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

enum ClimateCondition: String, CaseIterable {
    case cold = "Cold"
    case moderate = "Moderate"
    case hot = "Hot"
    case veryHot = "Very Hot"
    
    var description: String {
        switch self {
        case .cold:
            return "Below 10°C (50°F)"
        case .moderate:
            return "10-25°C (50-77°F)"
        case .hot:
            return "25-35°C (77-95°F)"
        case .veryHot:
            return "Above 35°C (95°F)"
        }
    }
}