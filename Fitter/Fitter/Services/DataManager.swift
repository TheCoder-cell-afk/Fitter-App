import Foundation
import SwiftUI

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var userProfile: UserProfile?
    @Published var currentFastingSession: FastingSession?
    @Published var foodEntries: [FoodEntry] = []
    @Published var exercises: [Exercise] = []
    @Published var hasCompletedOnboarding = false
    @Published var hasShownTutorial = false
    @Published var achievements: [Achievement] = []
    @Published var calorieLoggingStreak: Int = 0
    @Published var bestCalorieLoggingStreak: Int = 0
    private var lastCalorieLogDate: Date? = nil
    
    private let userDefaults = UserDefaults.standard
    private let notificationManager = NotificationManager.shared
    private let appGroupID = "group.com.yourcompany.Fitter"
    
    private init() {
        loadData()
    }
    
    // MARK: - User Profile
    func saveUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveData()
        
        // Schedule calorie logging notifications after onboarding
        notificationManager.scheduleCalorieLoggingNotifications()
    }
    
    func updateUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveData()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        // Sync with AppStorage
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        saveData()
    }
    
    func markTutorialAsShown() {
        hasShownTutorial = true
        // Sync with AppStorage
        UserDefaults.standard.set(true, forKey: "hasShownTutorial")
        saveData()
    }
    
    // MARK: - Fasting Session
    func startFastingSession(targetDuration: TimeInterval) {
        currentFastingSession = FastingSession(targetDuration: targetDuration)
        saveData()
        
        // Schedule notifications for fasting session
        notificationManager.scheduleFastingNotifications()
    }
    
    func startFastingSessionFromTime(targetDuration: TimeInterval, startTime: Date) {
        var session = FastingSession(targetDuration: targetDuration)
        session.startTime = startTime
        currentFastingSession = session
        saveData()
        
        // Schedule notifications for fasting session
        notificationManager.scheduleFastingNotifications()
    }
    
    func endFastingSession() {
        currentFastingSession?.endTime = Date()
        currentFastingSession?.isActive = false
        saveData()
        
        // Cancel fasting notifications when session ends
        notificationManager.cancelFastingNotifications()
        // Update fasting time achievement
        if let session = currentFastingSession {
            updateAchievements(for: .fastingTime, increment: Int(session.elapsedTime))
            updateStreakAchievements()
            
            // Award XP based on fasting duration
            let hours = Int(session.elapsedTime / 3600)
            let xpAmount = hours * 15 // 15 XP per hour fasted
            NotificationCenter.default.post(name: .init("AwardXP"), object: ["amount": xpAmount, "reason": "completing \(hours)-hour fast"])
        }
    }
    
    func addFastingSession(_ session: FastingSession) {
        // Add to completed sessions (you might want to store these separately)
        // For now, we'll just update achievements and award XP
        updateAchievements(for: .fastingTime, increment: Int(session.elapsedTime))
        updateStreakAchievements()
        
        // Award XP based on fasting duration
        let hours = Int(session.elapsedTime / 3600)
        let xpAmount = hours * 15 // 15 XP per hour fasted
        NotificationCenter.default.post(name: .init("AwardXP"), object: ["amount": xpAmount, "reason": "logging \(hours)-hour fast"])
        
        saveData()
    }
    
    // MARK: - Food Entries
    func addFoodEntry(_ entry: FoodEntry) {
        foodEntries.append(entry)
        updateCalorieLoggingStreak(for: entry.date)
        saveData()
        // Placeholder: treat all entries as healthy for demo
        updateAchievements(for: .healthyEating)
        
        // Award XP for logging food
        NotificationCenter.default.post(name: .init("AwardXP"), object: ["amount": 10, "reason": "logging food"])
    }
    
    func removeFoodEntry(_ entry: FoodEntry) {
        foodEntries.removeAll { $0.id == entry.id }
        saveData()
    }
    
    func getTodayFoodEntries() -> [FoodEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return foodEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    func getTodayNutrition() -> DailyNutrition {
        let todayEntries = getTodayFoodEntries()
        let totalCalories = todayEntries.reduce(0) { $0 + $1.calories }
        let totalProtein = todayEntries.reduce(0.0) { $0 + $1.protein }
        let totalCarbs = todayEntries.reduce(0.0) { $0 + $1.carbs }
        let totalFat = todayEntries.reduce(0.0) { $0 + $1.fat }
        
        let targetCalories = userProfile?.dailyCalorieTarget ?? 2000
        
        return DailyNutrition(
            date: Date(),
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbs: totalCarbs,
            totalFat: totalFat,
            targetCalories: targetCalories
        )
    }
    
    // MARK: - Exercise Entries
    func addExercise(_ exercise: Exercise) {
        exercises.append(exercise)
        saveData()
        updateAchievements(for: .exercise)
        
        // Award XP for logging exercise
        let xpAmount = Int(exercise.duration) * 2 // 2 XP per minute
        NotificationCenter.default.post(name: .init("AwardXP"), object: ["amount": xpAmount, "reason": "exercising for \(Int(exercise.duration)) minutes"])
    }
    
    func removeExercise(_ exercise: Exercise) {
        exercises.removeAll { $0.id == exercise.id }
        saveData()
    }
    
    func getTodayExercises() -> [Exercise] {
        let today = Calendar.current.startOfDay(for: Date())
        return exercises.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    func getTodayExerciseStats() -> (totalDuration: TimeInterval, totalCalories: Int) {
        let todayExercises = getTodayExercises()
        let totalDuration = todayExercises.reduce(0) { $0 + $1.duration }
        let totalCalories = todayExercises.reduce(0) { $0 + $1.caloriesBurned }
        return (totalDuration, totalCalories)
    }
    
    // MARK: - Data Persistence
    private func saveData() {
        if let profile = userProfile {
            if let encoded = try? JSONEncoder().encode(profile) {
                UserDefaults.standard.set(encoded, forKey: "userProfile")
            }
        }
        
        if let session = currentFastingSession {
            if let encoded = try? JSONEncoder().encode(session) {
                UserDefaults.standard.set(encoded, forKey: "currentFastingSession")
                if let sharedDefaults = UserDefaults(suiteName: appGroupID) {
                    sharedDefaults.set(encoded, forKey: "currentFastingSession")
                }
            }
        }
        
        if let encoded = try? JSONEncoder().encode(foodEntries) {
            UserDefaults.standard.set(encoded, forKey: "foodEntries")
        }
        
        if let encoded = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encoded, forKey: "exercises")
        }
        
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: "achievements")
        }
        UserDefaults.standard.set(calorieLoggingStreak, forKey: "calorieLoggingStreak")
        UserDefaults.standard.set(bestCalorieLoggingStreak, forKey: "bestCalorieLoggingStreak")
        UserDefaults.standard.set(lastCalorieLogDate, forKey: "lastCalorieLogDate")
    }
    
    private func loadData() {
        if let profileData = UserDefaults.standard.data(forKey: "userProfile") {
            do {
                let profile = try JSONDecoder().decode(UserProfile.self, from: profileData)
                userProfile = profile
                print("✅ UserProfile loaded successfully")
            } catch {
                print("❌ Failed to decode UserProfile: \(error)")
                print("🔄 Clearing corrupted profile data and starting fresh")
                UserDefaults.standard.removeObject(forKey: "userProfile")
                userProfile = nil
            }
        }
        
        if let sessionData = UserDefaults.standard.data(forKey: "currentFastingSession") {
            do {
                let session = try JSONDecoder().decode(FastingSession.self, from: sessionData)
                currentFastingSession = session
            } catch {
                print("❌ Failed to decode FastingSession: \(error)")
                UserDefaults.standard.removeObject(forKey: "currentFastingSession")
            }
        }
        
        if let entriesData = UserDefaults.standard.data(forKey: "foodEntries") {
            do {
                let entries = try JSONDecoder().decode([FoodEntry].self, from: entriesData)
                foodEntries = entries
            } catch {
                print("❌ Failed to decode FoodEntries: \(error)")
                UserDefaults.standard.removeObject(forKey: "foodEntries")
            }
        }
        
        if let exercisesData = UserDefaults.standard.data(forKey: "exercises") {
            do {
                let loadedExercises = try JSONDecoder().decode([Exercise].self, from: exercisesData)
                exercises = loadedExercises
            } catch {
                print("❌ Failed to decode Exercises: \(error)")
                UserDefaults.standard.removeObject(forKey: "exercises")
            }
        }
        
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if let achievementsData = UserDefaults.standard.data(forKey: "achievements"),
           let loadedAchievements = try? JSONDecoder().decode([Achievement].self, from: achievementsData) {
            achievements = loadedAchievements
        } else {
            achievements = AchievementFactory.defaultAchievements()
        }
        calorieLoggingStreak = UserDefaults.standard.integer(forKey: "calorieLoggingStreak")
        bestCalorieLoggingStreak = UserDefaults.standard.integer(forKey: "bestCalorieLoggingStreak")
        lastCalorieLogDate = UserDefaults.standard.object(forKey: "lastCalorieLogDate") as? Date
    }

    // MARK: - Achievement Logic
    func updateAchievements(for type: AchievementType, increment: Int = 1) {
        for i in achievements.indices {
            if achievements[i].type == type && !achievements[i].isUnlocked {
                achievements[i].progress += increment
                if achievements[i].progress >= achievements[i].goal {
                    achievements[i].isUnlocked = true
                }
            }
        }
        saveData()
    }
    
    // Streak logic: count consecutive fasting days
    private func updateStreakAchievements() {
        // Placeholder: increment streak by 1 for each fast ended
        updateAchievements(for: .streak)
    }
    
    // MARK: - Calorie Logging Streak
    private func updateCalorieLoggingStreak(for date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        let lastLog = lastCalorieLogDate != nil ? calendar.startOfDay(for: lastCalorieLogDate!) : nil
        if let last = lastLog {
            let daysBetween = calendar.dateComponents([.day], from: last, to: today).day ?? 0
            if daysBetween == 1 {
                calorieLoggingStreak += 1
            } else if daysBetween > 1 {
                calorieLoggingStreak = 1
            } // else, same day, do not increment
        } else {
            calorieLoggingStreak = 1
        }
        if calorieLoggingStreak > bestCalorieLoggingStreak {
            bestCalorieLoggingStreak = calorieLoggingStreak
        }
        lastCalorieLogDate = today
    }
    
    // MARK: - Debug and Reset Methods
    func clearAllData() {
        print("🗑️ Clearing all app data...")
        userProfile = nil
        currentFastingSession = nil
        foodEntries = []
        exercises = []
        hasCompletedOnboarding = false
        achievements = []
        calorieLoggingStreak = 0
        bestCalorieLoggingStreak = 0
        lastCalorieLogDate = nil
        
        // Clear UserDefaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        print("✅ All data cleared successfully")
    }
}

// MARK: - DataManager Extensions for Analytics
extension DataManager {
    func getFoods(from startDate: Date, to endDate: Date) -> [FoodEntry] {
        return foodEntries.filter { entry in
            entry.date >= startDate && entry.date < endDate
        }
    }
    
    func getExercises(from startDate: Date, to endDate: Date) -> [Exercise] {
        return exercises.filter { exercise in
            exercise.date >= startDate && exercise.date < endDate
        }
    }
    
    func getWaterEntries(from startDate: Date, to endDate: Date) -> [WaterEntry] {
        return WaterTrackerService.shared.waterEntries.filter { entry in
            entry.timestamp >= startDate && entry.timestamp < endDate
        }
    }
    
    func calculateDailyWaterGoal() -> Double {
        return WaterTrackerService.shared.dailyGoal
    }
    
    var fastingSessions: [FastingSession] {
        // Return completed and current fasting sessions
        var sessions: [FastingSession] = []
        if let current = currentFastingSession {
            sessions.append(current)
        }
        // Add any stored completed sessions if you have them
        return sessions
    }
    
    var foods: [FoodEntry] {
        return foodEntries
    }
} 