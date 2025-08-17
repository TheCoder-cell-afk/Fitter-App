import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationsEnabled = false
    
    private init() {
        checkNotificationStatus()
    }
    
    // MARK: - Notification Permission
    func requestNotificationPermission() {
        // First check current status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    // Request permission
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        DispatchQueue.main.async {
                            self.isNotificationsEnabled = granted
                        }
                        
                        if granted {
                            self.scheduleNotifications()
                        }
                    }
                case .authorized:
                    self.isNotificationsEnabled = true
                    self.scheduleNotifications()
                case .denied, .provisional, .ephemeral:
                    self.isNotificationsEnabled = false
                @unknown default:
                    self.isNotificationsEnabled = false
                }
            }
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Fasting Notifications
    func scheduleFastingNotifications() {
        guard isNotificationsEnabled else { return }
        
        // Cancel existing fasting notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["fasting_hourly"])
        
        // Schedule notifications for key fasting milestones (every 4 hours)
        let milestoneHours = [4, 8, 12, 16, 20, 24]
        
        for hour in milestoneHours {
            let content = UNMutableNotificationContent()
            content.title = getFastingPhaseTitle(hour: hour)
            content.body = getFastingPhaseMessage(hour: hour)
            content.sound = .default
            content.badge = NSNumber(value: hour)
            
            // Schedule for 4 hours from now (simplified for testing)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(hour * 3600), repeats: false)
            let request = UNNotificationRequest(
                identifier: "fasting_milestone_\(hour)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule fasting notification for hour \(hour): \(error)")
                } else {
                    print("Successfully scheduled fasting notification for hour \(hour)")
                }
            }
        }
    }
    
    func sendFastingNotification(hour: Int) {
        guard isNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = getFastingPhaseTitle(hour: hour)
        content.body = getFastingPhaseMessage(hour: hour)
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "fasting_phase_\(hour)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Calorie Logging Notifications
    func scheduleCalorieLoggingNotifications() {
        guard isNotificationsEnabled else { return }
        
        // Cancel existing calorie notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["calorie_reminder"])
        
        // Schedule notifications at specific meal times with better content
        let mealTimes = [
            (hour: 8, title: "🌅 Breakfast Time!", message: "Start your day right by logging your breakfast calories. Your body needs fuel to kickstart your metabolism!"),
            (hour: 12, title: "☀️ Lunch Time!", message: "Don't forget to log your lunch to stay on track with your goals. Balanced nutrition keeps you energized!"),
            (hour: 16, title: "🍎 Snack Time!", message: "Time for a healthy snack? Log it to maintain your calorie tracking. Choose nutrient-dense options!"),
            (hour: 19, title: "🌙 Dinner Time!", message: "Log your dinner calories to complete your daily nutrition tracking. End your day with mindful eating!"),
            (hour: 21, title: "📊 Evening Check-in", message: "Final reminder to log any remaining calories for today. Every entry helps you understand your patterns!")
        ]
        
        for (index, meal) in mealTimes.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = meal.title
            content.body = meal.message
            content.sound = .default
            content.badge = NSNumber(value: index + 1)
            
            // Create date components for specific times
            var dateComponents = DateComponents()
            dateComponents.hour = meal.hour
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "calorie_reminder_\(index)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule calorie notification for \(meal.title): \(error)")
                } else {
                    print("Successfully scheduled calorie notification for \(meal.title)")
                }
            }
        }
    }
    
    // MARK: - Fasting Phase Information
    private func getFastingPhaseTitle(hour: Int) -> String {
        switch hour {
        case 1...2:
            return "Early Fasting Phase"
        case 3...4:
            return "Glycogen Depletion"
        case 5...8:
            return "Fat Burning Begins"
        case 9...12:
            return "Ketosis Phase"
        case 13...16:
            return "Deep Ketosis"
        case 17...20:
            return "Autophagy Phase"
        case 21...24:
            return "Extended Fasting"
        default:
            return "Fasting Progress"
        }
    }
    
    private func getFastingPhaseMessage(hour: Int) -> String {
        let motivationalQuotes = [
            "Your body is becoming a fat-burning machine! 🔥",
            "Every hour of fasting brings you closer to your goals! 💪",
            "You're doing amazing! Your willpower is inspiring! ⭐",
            "Your body is thanking you for this fasting session! 🙏",
            "You're building healthy habits that last a lifetime! 🌟",
            "Your determination is transforming your health! 🎯",
            "You're stronger than your cravings! 💎",
            "Every moment of fasting is a victory! 🏆",
            "Your future self will thank you for this! 🌈",
            "You're creating the best version of yourself! ✨"
        ]
        
        let randomQuote = motivationalQuotes.randomElement() ?? "Keep going! You've got this!"
        
        switch hour {
        case 1...2:
            return "Your body is still using glucose from your last meal. Insulin levels are high. \(randomQuote)"
        case 3...4:
            return "Your body is starting to use stored glycogen. Blood sugar is decreasing. \(randomQuote)"
        case 5...8:
            return "Your body is switching to fat burning! Glycogen stores are depleting. \(randomQuote)"
        case 9...12:
            return "You're entering ketosis! Your body is now primarily burning fat for energy. \(randomQuote)"
        case 13...16:
            return "Deep ketosis! Your body is efficiently burning fat. Ketone levels are high. \(randomQuote)"
        case 17...20:
            return "Autophagy is beginning! Your body is cleaning up damaged cells. \(randomQuote)"
        case 21...24:
            return "Extended fasting benefits! Enhanced autophagy and fat burning. \(randomQuote)"
        default:
            return "You're doing great! Keep up the amazing work! \(randomQuote)"
        }
    }
    
    // MARK: - Fat Burning Calculations
    func calculateProjectedFatBurn(hours: Int, weight: Double) -> Double {
        // Rough estimation: 0.5-1.0 grams of fat per hour during fasting
        // This varies based on individual metabolism, activity level, etc.
        let fatBurnRate = 0.75 // grams per hour
        return Double(hours) * fatBurnRate
    }
    
    // MARK: - Notification Management
    func scheduleNotifications() {
        scheduleFastingNotifications()
        scheduleCalorieLoggingNotifications()
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelFastingNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["fasting_hourly"])
    }
    
    func cancelCalorieNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["calorie_reminder"])
    }
    
    // MARK: - Test Notifications
    func sendTestNotification() {
        guard isNotificationsEnabled else { 
            print("Notifications not enabled")
            return 
        }
        
        let content = UNMutableNotificationContent()
        content.title = "🎉 Fitter App Test"
        content.body = "This is a test notification to verify that notifications are working properly with full content display!"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_notification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send test notification: \(error)")
            } else {
                print("Test notification sent successfully")
            }
        }
    }
    
    func sendFastingProgressNotification(hour: Int) {
        guard isNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = getFastingPhaseTitle(hour: hour)
        content.body = getFastingPhaseMessage(hour: hour)
        content.sound = .default
        content.badge = NSNumber(value: hour)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "fasting_progress_\(hour)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send fasting progress notification: \(error)")
            } else {
                print("Fasting progress notification sent for hour \(hour)")
            }
        }
    }
}

// MARK: - Fasting Phase Enum
enum FastingPhase: String, CaseIterable {
    case earlyFasting = "Early Fasting"
    case glycogenDepletion = "Glycogen Depletion"
    case fatBurning = "Fat Burning"
    case ketosis = "Ketosis"
    case deepKetosis = "Deep Ketosis"
    case autophagy = "Autophagy"
    case extendedFasting = "Extended Fasting"
    
    var description: String {
        switch self {
        case .earlyFasting:
            return "Body using glucose from last meal"
        case .glycogenDepletion:
            return "Using stored glycogen, blood sugar decreasing"
        case .fatBurning:
            return "Switching to fat burning, glycogen depleting"
        case .ketosis:
            return "Entering ketosis, primarily burning fat"
        case .deepKetosis:
            return "Deep ketosis, efficient fat burning"
        case .autophagy:
            return "Cleaning up damaged cells"
        case .extendedFasting:
            return "Enhanced autophagy and fat burning"
        }
    }
    
    var benefits: [String] {
        switch self {
        case .earlyFasting:
            return ["Insulin levels high", "Glucose utilization"]
        case .glycogenDepletion:
            return ["Blood sugar decreasing", "Glycogen breakdown"]
        case .fatBurning:
            return ["Fat burning begins", "Metabolic switch"]
        case .ketosis:
            return ["Ketone production", "Fat as primary fuel"]
        case .deepKetosis:
            return ["High ketone levels", "Efficient fat burning"]
        case .autophagy:
            return ["Cellular cleanup", "Anti-aging benefits"]
        case .extendedFasting:
            return ["Enhanced autophagy", "Maximum fat burning"]
        }
    }
} 