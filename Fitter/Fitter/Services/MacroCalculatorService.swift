import Foundation

class MacroCalculatorService: ObservableObject {
    static let shared = MacroCalculatorService()
    
    private init() {}
    
    // MARK: - Enums
    enum Gender {
        case male, female
    }
    
    enum ActivityLevel: String, CaseIterable {
        case sedentary = "Sedentary"
        case lightlyActive = "Lightly Active"
        case moderatelyActive = "Moderately Active"
        case veryActive = "Very Active"
        case extraActive = "Extra Active"
        
        var description: String {
            switch self {
            case .sedentary:
                return "Little or no exercise"
            case .lightlyActive:
                return "Exercise 1-3 times/week"
            case .moderatelyActive:
                return "Exercise 4-5 times/week"
            case .veryActive:
                return "Daily exercise or intense exercise 3-4 times/week"
            case .extraActive:
                return "Intense exercise 6-7 times/week or physical job"
            }
        }
        
        var multiplier: Double {
            switch self {
            case .sedentary:
                return 1.2
            case .lightlyActive:
                return 1.375
            case .moderatelyActive:
                return 1.55
            case .veryActive:
                return 1.725
            case .extraActive:
                return 1.9
            }
        }
    }
    
    enum Goal: String, CaseIterable {
        case maintain = "Maintain Weight"
        case mildLoss = "Mild Weight Loss"
        case weightLoss = "Weight Loss"
        case extremeLoss = "Extreme Weight Loss"
        case mildGain = "Mild Weight Gain"
        case weightGain = "Weight Gain"
        case extremeGain = "Extreme Weight Gain"
        
        var calorieAdjustment: Int {
            switch self {
            case .maintain:
                return 0
            case .mildLoss:
                return -250  // 0.5 lb/week
            case .weightLoss:
                return -500  // 1 lb/week
            case .extremeLoss:
                return -1000 // 2 lb/week
            case .mildGain:
                return 250   // 0.5 lb/week
            case .weightGain:
                return 500   // 1 lb/week
            case .extremeGain:
                return 1000  // 2 lb/week
            }
        }
        
        var description: String {
            switch self {
            case .maintain:
                return "Maintain current weight"
            case .mildLoss:
                return "Lose 0.5 lb (0.25 kg) per week"
            case .weightLoss:
                return "Lose 1 lb (0.5 kg) per week"
            case .extremeLoss:
                return "Lose 2 lb (1 kg) per week"
            case .mildGain:
                return "Gain 0.5 lb (0.25 kg) per week"
            case .weightGain:
                return "Gain 1 lb (0.5 kg) per week"
            case .extremeGain:
                return "Gain 2 lb (1 kg) per week"
            }
        }
    }
    
    // MARK: - Data Models
    struct MacroCalculation {
        let bmr: Double
        let tdee: Double
        let targetCalories: Int
        let protein: MacroResult
        let carbs: MacroResult
        let fat: MacroResult
        let recommendations: [String]
    }
    
    struct MacroResult {
        let grams: Double
        let calories: Double
        let percentage: Double
    }
    
    // MARK: - BMR Calculation (Mifflin-St Jeor Equation)
    func calculateBMR(
        weight: Double, // in kg
        height: Double, // in cm
        age: Int,
        gender: Gender
    ) -> Double {
        let baseBMR = (10 * weight) + (6.25 * height) - (5 * Double(age))
        
        switch gender {
        case .male:
            return baseBMR + 5
        case .female:
            return baseBMR - 161
        }
    }
    
    // MARK: - Katch-McArdle Formula (if body fat is known)
    func calculateRDEE(
        weight: Double, // in kg
        bodyFatPercentage: Double
    ) -> Double {
        let leanBodyMass = weight * (1 - bodyFatPercentage / 100)
        return 370 + (21.6 * leanBodyMass)
    }
    
    // MARK: - TDEE Calculation
    func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
        return bmr * activityLevel.multiplier
    }
    
    // MARK: - Complete Macro Calculation
    func calculateMacros(
        weight: Double, // in kg
        height: Double, // in cm
        age: Int,
        gender: Gender,
        activityLevel: ActivityLevel,
        goal: Goal,
        bodyFatPercentage: Double? = nil
    ) -> MacroCalculation {
        
        // Calculate BMR using appropriate formula
        let bmr: Double
        if let bodyFat = bodyFatPercentage, bodyFat > 0 {
            // Use Katch-McArdle if body fat is available and person is lean
            bmr = calculateRDEE(weight: weight, bodyFatPercentage: bodyFat)
        } else {
            // Use Mifflin-St Jeor equation
            bmr = calculateBMR(weight: weight, height: height, age: age, gender: gender)
        }
        
        // Calculate TDEE
        let tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel)
        
        // Adjust for goal
        let targetCalories = max(
            Int(tdee) + goal.calorieAdjustment,
            gender == .female ? 1200 : 1500 // Minimum safe calories
        )
        
        // Calculate macros based on standard guidelines
        let macros = calculateMacroDistribution(targetCalories: targetCalories, weight: weight, goal: goal)
        
        // Generate recommendations
        let recommendations = generateRecommendations(
            targetCalories: targetCalories,
            gender: gender,
            goal: goal,
            activityLevel: activityLevel
        )
        
        return MacroCalculation(
            bmr: bmr,
            tdee: tdee,
            targetCalories: targetCalories,
            protein: macros.protein,
            carbs: macros.carbs,
            fat: macros.fat,
            recommendations: recommendations
        )
    }
    
    // MARK: - Macro Distribution
    private func calculateMacroDistribution(
        targetCalories: Int,
        weight: Double,
        goal: Goal
    ) -> (protein: MacroResult, carbs: MacroResult, fat: MacroResult) {
        
        // Protein: 0.8-2.2g per kg body weight (higher for muscle gain/loss)
        let proteinPerKg: Double
        switch goal {
        case .extremeLoss, .weightLoss:
            proteinPerKg = 2.0 // Higher protein to preserve muscle during deficit
        case .extremeGain, .weightGain:
            proteinPerKg = 1.8 // Higher protein for muscle building
        default:
            proteinPerKg = 1.4 // Moderate protein for maintenance
        }
        
        let proteinGrams = weight * proteinPerKg
        let proteinCalories = proteinGrams * 4 // 4 calories per gram
        let proteinPercentage = (proteinCalories / Double(targetCalories)) * 100
        
        // Fat: 20-35% of total calories (minimum 0.8g per kg for hormonal health)
        let fatPercentage: Double = 25 // 25% of calories from fat
        let fatCalories = Double(targetCalories) * (fatPercentage / 100)
        let fatGrams = fatCalories / 9 // 9 calories per gram
        
        // Carbs: Remaining calories
        let remainingCalories = Double(targetCalories) - proteinCalories - fatCalories
        let carbGrams = remainingCalories / 4 // 4 calories per gram
        let carbPercentage = (remainingCalories / Double(targetCalories)) * 100
        
        return (
            protein: MacroResult(
                grams: proteinGrams,
                calories: proteinCalories,
                percentage: proteinPercentage
            ),
            carbs: MacroResult(
                grams: carbGrams,
                calories: remainingCalories,
                percentage: carbPercentage
            ),
            fat: MacroResult(
                grams: fatGrams,
                calories: fatCalories,
                percentage: fatPercentage
            )
        )
    }
    
    // MARK: - Recommendations
    private func generateRecommendations(
        targetCalories: Int,
        gender: Gender,
        goal: Goal,
        activityLevel: ActivityLevel
    ) -> [String] {
        var recommendations: [String] = []
        
        // Calorie recommendations
        let minCalories = gender == .female ? 1200 : 1500
        if targetCalories <= minCalories {
            recommendations.append("⚠️ You're at minimum safe calorie intake. Consider a less aggressive deficit.")
        }
        
        // Goal-specific recommendations
        switch goal {
        case .extremeLoss:
            recommendations.append("🚨 Extreme weight loss should be supervised by a healthcare professional.")
            recommendations.append("💪 Focus on strength training to preserve muscle mass.")
        case .weightLoss:
            recommendations.append("🎯 Aim for 1-2 lbs weight loss per week for sustainable results.")
            recommendations.append("🥗 Focus on nutrient-dense, whole foods.")
        case .maintain:
            recommendations.append("⚖️ Perfect for maintaining current weight and body composition.")
        case .weightGain, .extremeGain:
            recommendations.append("💪 Combine with strength training for healthy muscle gain.")
            recommendations.append("🥑 Choose nutrient-dense calories over empty calories.")
        default:
            break
        }
        
        // Activity level recommendations
        switch activityLevel {
        case .sedentary:
            recommendations.append("🚶‍♂️ Consider adding light exercise to improve metabolism.")
        case .extraActive:
            recommendations.append("🏃‍♂️ Ensure adequate recovery between intense training sessions.")
        default:
            break
        }
        
        // General recommendations
        recommendations.append("💧 Drink plenty of water throughout the day.")
        recommendations.append("😴 Aim for 7-9 hours of quality sleep nightly.")
        recommendations.append("📊 Track your progress and adjust as needed.")
        
        return recommendations
    }
    
    // MARK: - Helper Functions
    func poundsToKg(_ pounds: Double) -> Double {
        return pounds * 0.453592
    }
    
    func feetInchesToCm(feet: Int, inches: Int) -> Double {
        let totalInches = Double(feet * 12 + inches)
        return totalInches * 2.54
    }
    
    func kgToPounds(_ kg: Double) -> Double {
        return kg / 0.453592
    }
    
    func cmToFeetInches(_ cm: Double) -> (feet: Int, inches: Int) {
        let totalInches = cm / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return (feet: feet, inches: inches)
    }
}