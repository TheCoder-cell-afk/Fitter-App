import Foundation

struct FastingSession: Codable, Identifiable {
    var id = UUID()
    var startTime: Date
    var endTime: Date?
    var targetDuration: TimeInterval
    var isActive: Bool
    
    var elapsedTime: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    var remainingTime: TimeInterval {
        max(0, targetDuration - elapsedTime)
    }
    
    var progress: Double {
        min(1.0, elapsedTime / targetDuration)
    }
    
    init(targetDuration: TimeInterval) {
        self.startTime = Date()
        self.targetDuration = targetDuration
        self.isActive = true
    }
}

 