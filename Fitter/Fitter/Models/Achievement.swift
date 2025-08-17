import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let type: AchievementType
    let goal: Int
    var isUnlocked: Bool = false
    var progress: Int = 0
    let iconName: String
}

enum AchievementType: String, Codable, CaseIterable {
    case fastingTime
    case healthyEating
    case streak
    case appUsage
    case exercise
} 