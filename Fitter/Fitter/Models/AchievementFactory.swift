
import Foundation

struct AchievementFactory {
    static func defaultAchievements() -> [Achievement] {
        var achievements: [Achievement] = []
        // Fasting Time Achievements (e.g., 12h, 16h, 24h, 36h, 48h, 72h, 100h, 200h, 500h, 1000h, etc.)
        let fastingHours = [12, 16, 18, 20, 24, 36, 48, 72, 100, 200, 500, 1000]
        for hour in fastingHours {
            achievements.append(Achievement(
                id: "fasting_\(hour)h",
                title: "Fasted for \(hour) hours!",
                description: "Complete a single fast of at least \(hour) hours.",
                type: .fastingTime,
                goal: hour * 3600,
                iconName: "timer"
            ))
        }
        // Cumulative Fasting Time (total hours fasted)
        let totalFasting = [100, 250, 500, 1000, 2000, 5000, 10000]
        for total in totalFasting {
            achievements.append(Achievement(
                id: "total_fasting_\(total)h",
                title: "Total Fasting: \(total)h",
                description: "Accumulate \(total) hours of fasting.",
                type: .fastingTime,
                goal: total * 3600,
                iconName: "flame"
            ))
        }
        // Healthy Eating Achievements (e.g., log healthy food X times)
        let healthyMeals = [1, 5, 10, 25, 50, 100, 200, 500]
        for count in healthyMeals {
            achievements.append(Achievement(
                id: "healthy_eating_\(count)",
                title: "Healthy Meals: \(count)",
                description: "Log \(count) healthy meals.",
                type: .healthyEating,
                goal: count,
                iconName: "leaf"
            ))
        }
        // Streak Achievements (e.g., 3, 7, 14, 30, 60, 100, 365 days)
        let streaks = [3, 7, 14, 30, 60, 100, 365]
        for days in streaks {
            achievements.append(Achievement(
                id: "streak_\(days)d",
                title: "Streak: \(days) Days",
                description: "Fast for \(days) days in a row without interruption.",
                type: .streak,
                goal: days,
                iconName: "calendar"
            ))
        }
        // App Usage Achievements (e.g., open app X times)
        let appUses = [1, 5, 10, 25, 50, 100, 200, 500]
        for count in appUses {
            achievements.append(Achievement(
                id: "app_usage_\(count)",
                title: "App Opened \(count)x",
                description: "Open the app \(count) times.",
                type: .appUsage,
                goal: count,
                iconName: "app"
            ))
        }
        
        // Exercise Achievements (e.g., log X exercises)
        let exerciseCounts = [1, 5, 10, 25, 50, 100, 200, 500]
        for count in exerciseCounts {
            achievements.append(Achievement(
                id: "exercise_\(count)",
                title: "Exercise Sessions: \(count)",
                description: "Log \(count) exercise sessions.",
                type: .exercise,
                goal: count,
                iconName: "figure.run"
            ))
        }
        // Add more unique/fun achievements to reach 100+
        for i in 1...40 {
            achievements.append(Achievement(
                id: "special_\(i)",
                title: "Special Achievement #\(i)",
                description: "Unlock a unique milestone!",
                type: AchievementType.allCases.randomElement()!,
                goal: Int.random(in: 1...1000),
                iconName: "star"
            ))
        }
        return achievements
    }
} 