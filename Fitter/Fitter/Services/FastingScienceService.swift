import Foundation

class FastingScienceService: ObservableObject {
    static let shared = FastingScienceService()
    
    private init() {}
    
    // MARK: - Fasting Phases and Ketosis Timeline
    struct FastingPhase {
        let name: String
        let description: String
        let startHour: Int
        let endHour: Int
        let primaryFuel: String
        let benefits: [String]
        let ketoneLevel: String
        let fatBurning: String
    }
    
    func getFastingPhases() -> [FastingPhase] {
        return [
            FastingPhase(
                name: "Post-Meal",
                description: "Body is digesting and using glucose from food",
                startHour: 0,
                endHour: 4,
                primaryFuel: "Glucose from food",
                benefits: ["Normal metabolism", "Energy from food"],
                ketoneLevel: "0.1-0.5 mmol/L",
                fatBurning: "Minimal"
            ),
            FastingPhase(
                name: "Glycogen Depletion",
                description: "Liver glycogen stores are being used for energy",
                startHour: 4,
                endHour: 8,
                primaryFuel: "Liver glycogen",
                benefits: ["Stable energy", "Blood sugar regulation"],
                ketoneLevel: "0.1-0.5 mmol/L",
                fatBurning: "Low"
            ),
            FastingPhase(
                name: "Early Fat Burning",
                description: "Body begins transitioning to fat metabolism",
                startHour: 8,
                endHour: 12,
                primaryFuel: "Glycogen + Fat",
                benefits: ["Fat burning begins", "Improved insulin sensitivity"],
                ketoneLevel: "0.5-1.0 mmol/L",
                fatBurning: "Moderate"
            ),
            FastingPhase(
                name: "Ketosis Begins",
                description: "Ketone production starts, fat burning accelerates",
                startHour: 12,
                endHour: 16,
                primaryFuel: "Fat + Ketones",
                benefits: ["Ketone production", "Enhanced fat burning", "Mental clarity"],
                ketoneLevel: "1.0-3.0 mmol/L",
                fatBurning: "High"
            ),
            FastingPhase(
                name: "Full Ketosis",
                description: "Maximum fat burning and ketone production",
                startHour: 16,
                endHour: 24,
                primaryFuel: "Fat + Ketones",
                benefits: ["Peak fat burning", "Maximum ketones", "Growth hormone increase"],
                ketoneLevel: "3.0-8.0 mmol/L",
                fatBurning: "Maximum"
            ),
            FastingPhase(
                name: "Deep Ketosis",
                description: "Autophagy begins, cellular cleanup starts",
                startHour: 24,
                endHour: 48,
                primaryFuel: "Fat + Ketones",
                benefits: ["Autophagy begins", "Cellular repair", "Anti-aging effects"],
                ketoneLevel: "5.0-10.0 mmol/L",
                fatBurning: "Maximum"
            )
        ]
    }
    
    // MARK: - Scientific Benefits by Duration
    func getBenefitsByDuration(hours: Int) -> [String] {
        switch hours {
        case 0..<4:
            return ["Normal post-meal metabolism", "Stable blood sugar"]
        case 4..<8:
            return ["Glycogen utilization", "Stable energy levels"]
        case 8..<12:
            return ["Fat burning begins", "Improved insulin sensitivity", "Blood sugar regulation"]
        case 12..<16:
            return ["Ketone production starts", "Enhanced fat burning", "Mental clarity", "Reduced hunger"]
        case 16..<24:
            return ["Peak fat burning", "Maximum ketone production", "Growth hormone increase", "Improved focus"]
        case 24..<48:
            return ["Autophagy begins", "Cellular repair", "Anti-aging effects", "Immune system boost"]
        default:
            return ["Extended fasting benefits", "Deep cellular repair", "Maximum autophagy"]
        }
    }
    
    // MARK: - Ketone Level Assessment
    func getKetoneLevel(hours: Int) -> (level: String, description: String) {
        switch hours {
        case 0..<12:
            return ("0.1-0.5 mmol/L", "Not in ketosis")
        case 12..<16:
            return ("1.0-3.0 mmol/L", "Light ketosis")
        case 16..<24:
            return ("3.0-8.0 mmol/L", "Full ketosis")
        case 24..<48:
            return ("5.0-10.0 mmol/L", "Deep ketosis")
        default:
            return ("8.0+ mmol/L", "Very deep ketosis")
        }
    }
    
    // MARK: - Fat Burning Assessment
    func getFatBurningStatus(hours: Int) -> (status: String, percentage: Double) {
        switch hours {
        case 0..<8:
            return ("Minimal", 0.1)
        case 8..<12:
            return ("Low", 0.3)
        case 12..<16:
            return ("Moderate", 0.6)
        case 16..<24:
            return ("High", 0.9)
        case 24..<48:
            return ("Maximum", 1.0)
        default:
            return ("Maximum", 1.0)
        }
    }
    
    // MARK: - Scientific Research Summary
    func getScientificSummary() -> String {
        return """
        **Scientific Evidence on Fasting and Ketosis:**
        
        **Fat Burning Timeline:**
        • 0-8 hours: Minimal fat burning, using glucose/glycogen
        • 8-12 hours: Fat burning begins, insulin sensitivity improves
        • 12-16 hours: Ketone production starts, fat burning accelerates
        • 16-24 hours: Peak fat burning and ketone production
        • 24+ hours: Maximum fat burning, autophagy begins
        
        **Key Scientific Findings:**
        • Ketosis typically begins at 12-16 hours of fasting
        • Maximum fat burning occurs at 16-24 hours
        • Growth hormone increases by 300-400% after 16 hours
        • Autophagy (cellular cleanup) begins at 24+ hours
        • Insulin sensitivity improves significantly after 12-16 hours
        
        **Health Benefits:**
        • Weight loss through fat burning
        • Improved metabolic health
        • Enhanced mental clarity
        • Cellular repair and anti-aging effects
        • Reduced inflammation
        """
    }
    
    // MARK: - Personalized Fasting Recommendations
    func getPersonalizedRecommendations(for goal: FastingGoal) -> [String] {
        switch goal {
        case .weightLoss:
            return [
                "Aim for 16-18 hour fasts for optimal fat burning",
                "Target ketosis phase (12+ hours) for maximum results",
                "Combine with moderate exercise for enhanced fat loss",
                "Focus on protein-rich meals during eating windows"
            ]
        case .muscleGain:
            return [
                "Use 12-14 hour fasts to preserve muscle mass",
                "Ensure adequate protein intake during eating windows",
                "Time workouts near the end of fasting periods",
                "Consider shorter fasts for muscle building"
            ]
        case .maintenance:
            return [
                "14-16 hour fasts for metabolic health",
                "Focus on balanced nutrition during eating windows",
                "Maintain consistent fasting schedule",
                "Monitor energy levels and adjust as needed"
            ]
        case .generalHealth:
            return [
                "16-18 hour fasts for optimal health benefits",
                "Target ketosis phase for cellular repair",
                "Include variety of nutrient-dense foods",
                "Listen to your body and adjust timing"
            ]
        }
    }
    
    // MARK: - Fasting Tips
    func getFastingTips() -> [String] {
        return [
            "Stay hydrated with water, black coffee, or tea",
            "Start with shorter fasts and gradually increase",
            "Listen to your body - don't push through extreme hunger",
            "Break your fast with nutrient-dense foods",
            "Monitor your energy levels and adjust accordingly",
            "Consider electrolytes during longer fasts",
            "Avoid breaking fasts with high-sugar foods",
            "Be patient - fat burning takes time to optimize"
        ]
    }
} 