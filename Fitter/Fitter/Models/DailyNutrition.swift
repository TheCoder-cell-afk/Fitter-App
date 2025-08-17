import Foundation

struct DailyNutrition: Codable {
    let date: Date
    let totalCalories: Int
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let targetCalories: Int
    
    var caloriesProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(Double(totalCalories) / Double(targetCalories), 1.0)
    }
    
    var proteinProgress: Double {
        let targetProtein = Double(targetCalories) * 0.3 / 4 // 30% of calories from protein
        guard targetProtein > 0 else { return 0 }
        return min(totalProtein / targetProtein, 1.0)
    }
    
    var carbsProgress: Double {
        let targetCarbs = Double(targetCalories) * 0.4 / 4 // 40% of calories from carbs
        guard targetCarbs > 0 else { return 0 }
        return min(totalCarbs / targetCarbs, 1.0)
    }
    
    var fatProgress: Double {
        let targetFat = Double(targetCalories) * 0.3 / 9 // 30% of calories from fat
        guard targetFat > 0 else { return 0 }
        return min(totalFat / targetFat, 1.0)
    }
    
    var remainingCalories: Int {
        return max(0, targetCalories - totalCalories)
    }
} 