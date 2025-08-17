import Foundation

struct UserProfile: Codable {
    var name: String
    var age: Int
    var gender: Gender
    var height: Double // in cm
    var weight: Double // in kg
    var activityLevel: ActivityLevel
    var fastingGoal: FastingGoal
    var fitnessGoal: FitnessGoal
    var dailyCalorieTarget: Int
    var bmr: Double?
    var tdee: Double?
    var proteinTarget: Double? // in grams
    var carbsTarget: Double? // in grams
    var fatTarget: Double? // in grams
    var bmi: Double? // Body Mass Index
    var bmiCategory: String? // BMI category name
    var weightGoal: Double? // Target weight in kg
    var gamificationEnabled: Bool // Whether user wants gamification features
    // All units: height in centimeters, weight in kilograms
    
    init(name: String, age: Int, gender: Gender, height: Double, weight: Double, activityLevel: ActivityLevel, fastingGoal: FastingGoal, fitnessGoal: FitnessGoal, dailyCalorieTarget: Int, bmr: Double? = nil, tdee: Double? = nil, proteinTarget: Double? = nil, carbsTarget: Double? = nil, fatTarget: Double? = nil, bmi: Double? = nil, bmiCategory: String? = nil, weightGoal: Double? = nil, gamificationEnabled: Bool = true) {
        self.name = name
        self.age = age
        self.gender = gender
        self.height = height
        self.weight = weight
        self.activityLevel = activityLevel
        self.fastingGoal = fastingGoal
        self.fitnessGoal = fitnessGoal
        self.dailyCalorieTarget = dailyCalorieTarget
        self.bmr = bmr
        self.tdee = tdee
        self.proteinTarget = proteinTarget
        self.carbsTarget = carbsTarget
        self.fatTarget = fatTarget
        self.bmi = bmi
        self.bmiCategory = bmiCategory
        self.weightGoal = weightGoal
        self.gamificationEnabled = gamificationEnabled
    }
    
    // MARK: - Codable Implementation for Backward Compatibility
    enum CodingKeys: String, CodingKey {
        case name, age, gender, height, weight, activityLevel, fastingGoal, fitnessGoal
        case dailyCalorieTarget, bmr, tdee, proteinTarget, carbsTarget, fatTarget
        case bmi, bmiCategory, weightGoal, gamificationEnabled
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        gender = try container.decode(Gender.self, forKey: .gender)
        height = try container.decode(Double.self, forKey: .height)
        weight = try container.decode(Double.self, forKey: .weight)
        activityLevel = try container.decode(ActivityLevel.self, forKey: .activityLevel)
        fastingGoal = try container.decode(FastingGoal.self, forKey: .fastingGoal)
        fitnessGoal = try container.decode(FitnessGoal.self, forKey: .fitnessGoal)
        dailyCalorieTarget = try container.decode(Int.self, forKey: .dailyCalorieTarget)
        
        // Optional properties with backward compatibility
        bmr = try container.decodeIfPresent(Double.self, forKey: .bmr)
        tdee = try container.decodeIfPresent(Double.self, forKey: .tdee)
        proteinTarget = try container.decodeIfPresent(Double.self, forKey: .proteinTarget)
        carbsTarget = try container.decodeIfPresent(Double.self, forKey: .carbsTarget)
        fatTarget = try container.decodeIfPresent(Double.self, forKey: .fatTarget)
        bmi = try container.decodeIfPresent(Double.self, forKey: .bmi)
        bmiCategory = try container.decodeIfPresent(String.self, forKey: .bmiCategory)
        weightGoal = try container.decodeIfPresent(Double.self, forKey: .weightGoal)
        gamificationEnabled = try container.decodeIfPresent(Bool.self, forKey: .gamificationEnabled) ?? true
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)
        try container.encode(gender, forKey: .gender)
        try container.encode(height, forKey: .height)
        try container.encode(weight, forKey: .weight)
        try container.encode(activityLevel, forKey: .activityLevel)
        try container.encode(fastingGoal, forKey: .fastingGoal)
        try container.encode(fitnessGoal, forKey: .fitnessGoal)
        try container.encode(dailyCalorieTarget, forKey: .dailyCalorieTarget)
        
        try container.encodeIfPresent(bmr, forKey: .bmr)
        try container.encodeIfPresent(tdee, forKey: .tdee)
        try container.encodeIfPresent(proteinTarget, forKey: .proteinTarget)
        try container.encodeIfPresent(carbsTarget, forKey: .carbsTarget)
        try container.encodeIfPresent(fatTarget, forKey: .fatTarget)
        try container.encodeIfPresent(bmi, forKey: .bmi)
        try container.encodeIfPresent(bmiCategory, forKey: .bmiCategory)
        try container.encodeIfPresent(weightGoal, forKey: .weightGoal)
        try container.encodeIfPresent(gamificationEnabled, forKey: .gamificationEnabled)
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extremelyActive = "Extremely Active"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extremelyActive: return 1.9
        }
    }
}

enum FastingGoal: String, CaseIterable, Codable {
    case weightLoss = "Weight Loss"
    case maintenance = "Maintenance"
    case muscleGain = "Muscle Gain"
    case generalHealth = "General Health"
}

enum FitnessGoal: String, CaseIterable, Codable {
    case fatLoss = "Fat Loss"
    case maintenance = "Maintenance"
    case muscleGain = "Muscle Gain"
} 