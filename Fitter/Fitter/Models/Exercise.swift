import Foundation

struct Exercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let duration: TimeInterval // in minutes
    let caloriesBurned: Int
    let type: ExerciseType
    let date: Date
    let notes: String?
    
    init(name: String, duration: TimeInterval, caloriesBurned: Int, type: ExerciseType, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.type = type
        self.date = Date()
        self.notes = notes
    }
}

enum ExerciseType: String, CaseIterable, Codable {
    case cardio = "Cardio"
    case strength = "Strength"
    case flexibility = "Flexibility"
    case sports = "Sports"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .cardio:
            return "heart.fill"
        case .strength:
            return "dumbbell.fill"
        case .flexibility:
            return "figure.flexibility"
        case .sports:
            return "sportscourt.fill"
        case .other:
            return "figure.mixed.cardio"
        }
    }
    
    var color: String {
        switch self {
        case .cardio:
            return "red"
        case .strength:
            return "blue"
        case .flexibility:
            return "green"
        case .sports:
            return "orange"
        case .other:
            return "purple"
        }
    }
} 