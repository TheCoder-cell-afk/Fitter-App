import Foundation

class CalorieCalculator {
    static func calculateBMR(age: Int, gender: Gender, weight: Double, height: Double) -> Double {
        // Mifflin-St Jeor Equation (weight in kg, height in cm)
        let bmr: Double
        switch gender {
        case .male:
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
        case .female:
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
        case .other:
            // Use average of male and female calculation
            let maleBMR = (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
            let femaleBMR = (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
            bmr = (maleBMR + femaleBMR) / 2
        }
        return bmr
    }
    
    static func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        return bmr * activityLevel.multiplier
    }
    
    static func calculateTargetCalories(tdee: Double, fitnessGoal: FitnessGoal) -> Int {
        switch fitnessGoal {
        case .fatLoss:
            return Int(round(tdee * 0.8))
        case .maintenance:
            return Int(round(tdee))
        case .muscleGain:
            return Int(round(tdee * 1.1))
        }
    }
    
    static func calculateDailyTargets(for profile: UserProfile) -> (calories: Int, protein: Double, carbs: Double, fat: Double) {
        let bmr = calculateBMR(age: profile.age, gender: profile.gender, weight: profile.weight, height: profile.height)
        let tdee = calculateTDEE(bmr: bmr, activityLevel: profile.activityLevel)
        let calories = calculateTargetCalories(tdee: tdee, fitnessGoal: profile.fitnessGoal)
        let protein = profile.weight * 2.0 // 2g per kg body weight
        let fat = (Double(calories) * 0.25) / 9 // 25% of calories from fat
        let carbs = (Double(calories) - (protein * 4) - (fat * 9)) / 4 // remaining calories from carbs
        return (calories, protein, carbs, fat)
    }
} 