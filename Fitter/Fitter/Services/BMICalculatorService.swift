import Foundation

class BMICalculatorService: ObservableObject {
    static let shared = BMICalculatorService()
    
    private init() {}
    
    // MARK: - Data Models
    struct BMIResult {
        let bmi: Double
        let category: BMICategory
        let healthyWeightRange: (min: Double, max: Double) // in kg
        let recommendations: [String]
    }
    
    enum BMICategory: String, CaseIterable {
        case underweight = "Underweight"
        case normal = "Normal weight"
        case overweight = "Overweight"
        case obeseClass1 = "Obesity Class I"
        case obeseClass2 = "Obesity Class II"
        case obeseClass3 = "Obesity Class III"
        
        var range: String {
            switch self {
            case .underweight:
                return "Below 18.5"
            case .normal:
                return "18.5 - 24.9"
            case .overweight:
                return "25.0 - 29.9"
            case .obeseClass1:
                return "30.0 - 34.9"
            case .obeseClass2:
                return "35.0 - 39.9"
            case .obeseClass3:
                return "40.0 and above"
            }
        }
        
        var color: String {
            switch self {
            case .underweight:
                return "blue"
            case .normal:
                return "green"
            case .overweight:
                return "yellow"
            case .obeseClass1:
                return "orange"
            case .obeseClass2:
                return "red"
            case .obeseClass3:
                return "purple"
            }
        }
        
        var description: String {
            switch self {
            case .underweight:
                return "Below normal weight"
            case .normal:
                return "Healthy weight range"
            case .overweight:
                return "Above normal weight"
            case .obeseClass1:
                return "Moderately obese"
            case .obeseClass2:
                return "Severely obese"
            case .obeseClass3:
                return "Very severely obese"
            }
        }
    }
    
    // MARK: - BMI Calculation
    func calculateBMI(
        weight: Double, // in kg
        height: Double  // in cm
    ) -> BMIResult {
        // Convert height from cm to meters
        let heightInMeters = height / 100
        
        // Calculate BMI: weight (kg) / height (m)²
        let bmi = weight / (heightInMeters * heightInMeters)
        
        // Determine category
        let category = getBMICategory(bmi: bmi)
        
        // Calculate healthy weight range for this height
        let healthyWeightRange = getHealthyWeightRange(height: height)
        
        // Generate recommendations
        let recommendations = generateRecommendations(bmi: bmi, category: category, currentWeight: weight, healthyRange: healthyWeightRange)
        
        return BMIResult(
            bmi: bmi,
            category: category,
            healthyWeightRange: healthyWeightRange,
            recommendations: recommendations
        )
    }
    
    // MARK: - Helper Functions
    private func getBMICategory(bmi: Double) -> BMICategory {
        switch bmi {
        case 0..<18.5:
            return .underweight
        case 18.5..<25.0:
            return .normal
        case 25.0..<30.0:
            return .overweight
        case 30.0..<35.0:
            return .obeseClass1
        case 35.0..<40.0:
            return .obeseClass2
        default:
            return .obeseClass3
        }
    }
    
    private func getHealthyWeightRange(height: Double) -> (min: Double, max: Double) {
        // Convert height from cm to meters
        let heightInMeters = height / 100
        
        // Healthy BMI range is 18.5 - 24.9
        let minWeight = 18.5 * (heightInMeters * heightInMeters)
        let maxWeight = 24.9 * (heightInMeters * heightInMeters)
        
        return (min: minWeight, max: maxWeight)
    }
    
    private func generateRecommendations(
        bmi: Double,
        category: BMICategory,
        currentWeight: Double,
        healthyRange: (min: Double, max: Double)
    ) -> [String] {
        var recommendations: [String] = []
        
        switch category {
        case .underweight:
            let weightToGain = healthyRange.min - currentWeight
            recommendations.append("⬆️ Consider gaining \(String(format: "%.1f", weightToGain)) kg to reach a healthy weight.")
            recommendations.append("🍽️ Focus on nutrient-dense, calorie-rich foods.")
            recommendations.append("💪 Include strength training to build muscle mass.")
            recommendations.append("👨‍⚕️ Consult a healthcare provider about healthy weight gain.")
            
        case .normal:
            recommendations.append("✅ You're in a healthy weight range!")
            recommendations.append("🏃‍♂️ Maintain your current weight with regular exercise.")
            recommendations.append("🥗 Continue eating a balanced, nutritious diet.")
            recommendations.append("📊 Monitor your weight regularly to stay in this range.")
            
        case .overweight:
            let weightToLose = currentWeight - healthyRange.max
            recommendations.append("⬇️ Consider losing \(String(format: "%.1f", weightToLose)) kg to reach a healthy weight.")
            recommendations.append("🏃‍♂️ Aim for 150+ minutes of moderate exercise per week.")
            recommendations.append("🍎 Focus on whole foods and reduce processed foods.")
            recommendations.append("💧 Stay hydrated and get adequate sleep.")
            
        case .obeseClass1:
            let weightToLose = currentWeight - healthyRange.max
            recommendations.append("⬇️ Consider losing \(String(format: "%.1f", weightToLose)) kg to reach a healthy weight.")
            recommendations.append("👨‍⚕️ Consult a healthcare provider for a weight loss plan.")
            recommendations.append("🍽️ Consider working with a registered dietitian.")
            recommendations.append("🏋️‍♂️ Start with low-impact exercises like walking or swimming.")
            
        case .obeseClass2, .obeseClass3:
            recommendations.append("🚨 This BMI category may increase health risks.")
            recommendations.append("👨‍⚕️ Strongly consider consulting a healthcare provider.")
            recommendations.append("🏥 Medical supervision may be beneficial for weight loss.")
            recommendations.append("🫀 Monitor cardiovascular health regularly.")
            recommendations.append("💊 Discuss potential medical interventions with your doctor.")
        }
        
        // General recommendations for all categories
        recommendations.append("🩺 Regular health check-ups are important.")
        recommendations.append("😴 Aim for 7-9 hours of quality sleep nightly.")
        
        return recommendations
    }
    
    // MARK: - Unit Conversion Helpers
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