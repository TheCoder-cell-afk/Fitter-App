import Foundation

struct FastingPlan {
    let name: String
    let description: String
    let fastingWindow: TimeInterval // in hours
    let eatingWindow: TimeInterval // in hours
    let totalHours: TimeInterval
    
    init(name: String, description: String, fastingWindow: TimeInterval, eatingWindow: TimeInterval) {
        self.name = name
        self.description = description
        self.fastingWindow = fastingWindow
        self.eatingWindow = eatingWindow
        self.totalHours = fastingWindow + eatingWindow
    }
    
    static func defaultPlan(for goal: FastingGoal) -> FastingPlan {
        switch goal {
        case .weightLoss:
            return FastingPlan(
                name: "16:8 Weight Loss",
                description: "16 hours fasting, 8 hours eating window. Optimal for weight loss and fat burning.",
                fastingWindow: 16 * 3600, // 16 hours in seconds
                eatingWindow: 8 * 3600 // 8 hours in seconds
            )
        case .maintenance:
            return FastingPlan(
                name: "14:10 Maintenance",
                description: "14 hours fasting, 10 hours eating window. Good for maintaining current weight.",
                fastingWindow: 14 * 3600, // 14 hours in seconds
                eatingWindow: 10 * 3600 // 10 hours in seconds
            )
        case .muscleGain:
            return FastingPlan(
                name: "12:12 Muscle Gain",
                description: "12 hours fasting, 12 hours eating window. Balanced approach for muscle building.",
                fastingWindow: 12 * 3600, // 12 hours in seconds
                eatingWindow: 12 * 3600 // 12 hours in seconds
            )
        case .generalHealth:
            return FastingPlan(
                name: "16:8 General Health",
                description: "16 hours fasting, 8 hours eating window. Promotes autophagy and cellular health.",
                fastingWindow: 16 * 3600, // 16 hours in seconds
                eatingWindow: 8 * 3600 // 8 hours in seconds
            )
        }
    }
    
    static func planForActivityLevel(_ activityLevel: ActivityLevel) -> FastingPlan {
        switch activityLevel {
        case .sedentary:
            return FastingPlan(
                name: "18:6 Sedentary",
                description: "18 hours fasting, 6 hours eating. Recommended for sedentary individuals.",
                fastingWindow: 18 * 3600,
                eatingWindow: 6 * 3600
            )
        case .lightlyActive:
            return FastingPlan(
                name: "16:8 Lightly Active",
                description: "16 hours fasting, 8 hours eating. Good for lightly active individuals.",
                fastingWindow: 16 * 3600,
                eatingWindow: 8 * 3600
            )
        case .moderatelyActive:
            return FastingPlan(
                name: "16:8 Moderately Active",
                description: "16 hours fasting, 8 hours eating. Balanced for moderately active individuals.",
                fastingWindow: 16 * 3600,
                eatingWindow: 8 * 3600
            )
        case .veryActive:
            return FastingPlan(
                name: "14:10 Very Active",
                description: "14 hours fasting, 10 hours eating. Suitable for very active individuals.",
                fastingWindow: 14 * 3600,
                eatingWindow: 10 * 3600
            )
        case .extremelyActive:
            return FastingPlan(
                name: "12:12 Extremely Active",
                description: "12 hours fasting, 12 hours eating. Recommended for extremely active individuals.",
                fastingWindow: 12 * 3600,
                eatingWindow: 12 * 3600
            )
        }
    }
    
    static let allPlans: [FastingPlan] = [
        FastingPlan(name: "12:12", description: "12 hours fasting, 12 hours eating", fastingWindow: 12 * 3600, eatingWindow: 12 * 3600),
        FastingPlan(name: "14:10", description: "14 hours fasting, 10 hours eating", fastingWindow: 14 * 3600, eatingWindow: 10 * 3600),
        FastingPlan(name: "16:8", description: "16 hours fasting, 8 hours eating", fastingWindow: 16 * 3600, eatingWindow: 8 * 3600),
        FastingPlan(name: "18:6", description: "18 hours fasting, 6 hours eating", fastingWindow: 18 * 3600, eatingWindow: 6 * 3600),
        FastingPlan(name: "20:4", description: "20 hours fasting, 4 hours eating", fastingWindow: 20 * 3600, eatingWindow: 4 * 3600)
    ]
} 