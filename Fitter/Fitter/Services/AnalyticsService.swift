import Foundation
import Combine

// MARK: - Analytics Models
struct HealthScore {
    let overall: Double
    let nutrition: Double
    let activity: Double
    let hydration: Double
    let fasting: Double
    let date: Date
    
    init(nutrition: Double = 0, activity: Double = 0, hydration: Double = 0, fasting: Double = 0) {
        self.nutrition = min(max(nutrition, 0), 100)
        self.activity = min(max(activity, 0), 100)
        self.hydration = min(max(hydration, 0), 100)
        self.fasting = min(max(fasting, 0), 100)
        
        // Weighted average: Nutrition 40%, Activity 30%, Hydration 15%, Fasting 15%
        self.overall = (nutrition * 0.4) + (activity * 0.3) + (hydration * 0.15) + (fasting * 0.15)
        self.date = Date()
    }
}

struct SmartInsight {
    let id = UUID()
    let title: String
    let description: String
    let impact: Double // -100 to 100 (negative = harmful, positive = beneficial)
    let category: InsightCategory
    let actionable: Bool
    let recommendation: String?
    let confidence: Double // 0-100 (how confident we are in this insight)
    
    enum InsightCategory {
        case correlation, prediction, optimization, warning, achievement
    }
}

struct TrendData {
    let metric: String
    let values: [Double]
    let dates: [Date]
    let trend: TrendDirection
    let velocity: Double // Rate of change
    let prediction: Double? // Predicted next value
    
    enum TrendDirection {
        case improving, declining, stable, volatile
    }
}

struct AnalyticsReport {
    let date: Date
    let healthScore: HealthScore
    let insights: [SmartInsight]
    let trends: [TrendData]
    let predictions: [String]
    let recommendations: [String]
}

// MARK: - Analytics Service
class AnalyticsService: ObservableObject {
    @Published var currentHealthScore: HealthScore?
    @Published var weeklyScores: [HealthScore] = []
    @Published var smartInsights: [SmartInsight] = []
    @Published var trends: [TrendData] = []
    @Published var isCalculating = false
    
    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        setupDataObservation()
        calculateAnalytics()
    }
    
    private func setupDataObservation() {
        // Update analytics when data changes
        dataManager.objectWillChange
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.calculateAnalytics()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Health Score Calculation
    func calculateHealthScore(for date: Date = Date()) -> HealthScore {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        let nutritionScore = calculateNutritionScore(from: startOfDay, to: endOfDay)
        let activityScore = calculateActivityScore(from: startOfDay, to: endOfDay)
        let hydrationScore = calculateHydrationScore(from: startOfDay, to: endOfDay)
        let fastingScore = calculateFastingScore(from: startOfDay, to: endOfDay)
        
        return HealthScore(
            nutrition: nutritionScore,
            activity: activityScore,
            hydration: hydrationScore,
            fasting: fastingScore
        )
    }
    
    private func calculateNutritionScore(from startDate: Date, to endDate: Date) -> Double {
        let foods = dataManager.getFoods(from: startDate, to: endDate)
        guard !foods.isEmpty else { return 0 }
        
        let totalCalories = Double(foods.reduce(0) { $0 + $1.calories })
        let totalProtein = foods.reduce(0.0) { $0 + $1.protein }
        let totalCarbs = foods.reduce(0.0) { $0 + $1.carbs }
        let totalFat = foods.reduce(0.0) { $0 + $1.fat }
        
        // Get user's targets from profile
        let profile = dataManager.userProfile
        let calorieTarget = profile?.tdee ?? 2000
        let proteinTarget = profile?.proteinTarget ?? 120
        let carbsTarget = profile?.carbsTarget ?? 200
        let fatTarget = profile?.fatTarget ?? 70
        
        // Calculate compliance scores (0-100)
        let calorieScore = min(100, max(0, 100 - abs(totalCalories - calorieTarget) / calorieTarget * 100))
        let proteinScore = min(100, (totalProtein / proteinTarget) * 100)
        let carbsScore = min(100, max(0, 100 - abs(totalCarbs - carbsTarget) / carbsTarget * 100))
        let fatScore = min(100, max(0, 100 - abs(totalFat - fatTarget) / fatTarget * 100))
        
        // Weighted average: Calories 30%, Protein 40%, Carbs 15%, Fat 15%
        return (calorieScore * 0.3) + (proteinScore * 0.4) + (carbsScore * 0.15) + (fatScore * 0.15)
    }
    
    private func calculateActivityScore(from startDate: Date, to endDate: Date) -> Double {
        let exercises = dataManager.getExercises(from: startDate, to: endDate)
        
        if exercises.isEmpty {
            return 0
        }
        
        let totalDuration = exercises.reduce(0) { $0 + $1.duration }
        let uniqueTypes = Set(exercises.map { $0.type }).count
        
        // Base score from duration (target: 30+ minutes)
        let durationScore = min(100, (totalDuration / 30) * 100)
        
        // Bonus for variety (different exercise types)
        let varietyBonus = min(20, Double(uniqueTypes) * 5)
        
        return min(100, durationScore + varietyBonus)
    }
    
    private func calculateHydrationScore(from startDate: Date, to endDate: Date) -> Double {
        let waterEntries = dataManager.getWaterEntries(from: startDate, to: endDate)
        let totalWater = waterEntries.reduce(0) { $0 + $1.amount }
        
        let dailyGoal = dataManager.calculateDailyWaterGoal()
        return min(100, (totalWater / dailyGoal) * 100)
    }
    
    private func calculateFastingScore(from startDate: Date, to endDate: Date) -> Double {
        guard let currentSession = dataManager.currentFastingSession else {
            // Check if there was a completed session today
            let completedSessions = dataManager.fastingSessions.filter { session in
                session.endTime != nil &&
                Calendar.current.isDate(session.startTime, inSameDayAs: startDate)
            }
            
            if let lastSession = completedSessions.last {
                let duration = lastSession.endTime!.timeIntervalSince(lastSession.startTime)
                let targetDuration = Double(lastSession.targetDuration) * 3600
                return min(100, (duration / targetDuration) * 100)
            }
            return 0
        }
        
        let elapsedTime = currentSession.elapsedTime
        let targetDuration = Double(currentSession.targetDuration) * 3600
        
        return min(100, (elapsedTime / targetDuration) * 100)
    }
    
    // MARK: - Smart Insights Generation
    func generateSmartInsights() -> [SmartInsight] {
        var insights: [SmartInsight] = []
        
        // Correlation insights
        insights.append(contentsOf: generateCorrelationInsights())
        
        // Performance insights
        insights.append(contentsOf: generatePerformanceInsights())
        
        // Behavioral insights
        insights.append(contentsOf: generateBehavioralInsights())
        
        // Prediction insights
        insights.append(contentsOf: generatePredictionInsights())
        
        return insights.sorted { $0.confidence > $1.confidence }
    }
    
    private func generateCorrelationInsights() -> [SmartInsight] {
        var insights: [SmartInsight] = []
        
        // Water and exercise correlation
        if let waterExerciseCorrelation = calculateWaterExerciseCorrelation() {
            insights.append(waterExerciseCorrelation)
        }
        
        // Fasting and performance correlation
        if let fastingPerformanceCorrelation = calculateFastingPerformanceCorrelation() {
            insights.append(fastingPerformanceCorrelation)
        }
        
        // Nutrition timing insights
        if let nutritionTimingInsight = calculateNutritionTimingInsight() {
            insights.append(nutritionTimingInsight)
        }
        
        return insights
    }
    
    private func calculateWaterExerciseCorrelation() -> SmartInsight? {
        // Get daily water and exercise data for last 30 days
        var dailyData: [(water: Double, exercise: Double)] = []
        
        for i in 0..<30 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? date
            
            let waterEntries = dataManager.getWaterEntries(from: startOfDay, to: endOfDay)
            let exercises = dataManager.getExercises(from: startOfDay, to: endOfDay)
            
            let totalWater = waterEntries.reduce(0) { $0 + $1.amount }
            let totalExercise = exercises.reduce(0) { $0 + $1.duration }
            
            dailyData.append((water: totalWater, exercise: totalExercise))
        }
        
        guard dailyData.count > 10 else { return nil }
        
        // Simple correlation calculation
        let waterMean = dailyData.map { $0.water }.reduce(0, +) / Double(dailyData.count)
        let exerciseMean = dailyData.map { $0.exercise }.reduce(0, +) / Double(dailyData.count)
        
        let correlation = calculateCorrelation(
            data1: dailyData.map { $0.water - waterMean },
            data2: dailyData.map { $0.exercise - exerciseMean }
        )
        
        guard abs(correlation) > 0.3 else { return nil } // Only show if moderate correlation
        
        let impact = correlation * 50 // Scale to our impact range
        let percentage = Int(abs(correlation) * 100)
        
        if correlation > 0 {
            return SmartInsight(
                title: "Hydration Boosts Exercise",
                description: "You exercise \(percentage)% more on days when you're well-hydrated",
                impact: impact,
                category: .correlation,
                actionable: true,
                recommendation: "Try drinking 500ml of water 30 minutes before your planned workout",
                confidence: min(90, abs(correlation) * 100)
            )
        } else {
            return SmartInsight(
                title: "Exercise Affects Hydration",
                description: "Your water intake drops \(percentage)% on intense exercise days",
                impact: impact,
                category: .warning,
                actionable: true,
                recommendation: "Set reminders to drink water during and after workouts",
                confidence: min(90, abs(correlation) * 100)
            )
        }
    }
    
    private func calculateFastingPerformanceCorrelation() -> SmartInsight? {
        let completedSessions = dataManager.fastingSessions.filter { $0.endTime != nil }
        guard completedSessions.count > 5 else { return nil }
        
        let successfulSessions = completedSessions.filter { session in
            let duration = session.endTime!.timeIntervalSince(session.startTime)
            let targetDuration = Double(session.targetDuration) * 3600
            return duration >= targetDuration * 0.9 // 90% completion is "successful"
        }
        
        let successRate = Double(successfulSessions.count) / Double(completedSessions.count) * 100
        
        if successRate > 80 {
            return SmartInsight(
                title: "Fasting Champion",
                description: "You complete \(Int(successRate))% of your fasting goals",
                impact: 30,
                category: .achievement,
                actionable: false,
                recommendation: nil,
                confidence: 95
            )
        } else if successRate < 50 {
            return SmartInsight(
                title: "Fasting Optimization Needed",
                description: "Your fasting completion rate is \(Int(successRate))%",
                impact: -20,
                category: .warning,
                actionable: true,
                recommendation: "Try shorter fasting windows (12-14 hours) to build consistency",
                confidence: 85
            )
        }
        
        return nil
    }
    
    private func calculateNutritionTimingInsight() -> SmartInsight? {
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        let foods = dataManager.getFoods(from: fourteenDaysAgo, to: Date())
        
        guard foods.count > 20 else { return nil }
        
        // Analyze meal timing patterns
        let mealTimes = foods.map { Calendar.current.component(.hour, from: $0.date) }
        let averageMealTime = Double(mealTimes.reduce(0, +)) / Double(mealTimes.count)
        
        if averageMealTime < 10 {
            return SmartInsight(
                title: "Early Bird Eater",
                description: "You tend to eat most meals before 10 AM",
                impact: 15,
                category: .correlation,
                actionable: true,
                recommendation: "Your eating pattern supports intermittent fasting - consider a 16:8 schedule",
                confidence: 70
            )
        } else if averageMealTime > 20 {
            return SmartInsight(
                title: "Late Night Eating Pattern",
                description: "Most of your meals happen after 8 PM",
                impact: -10,
                category: .warning,
                actionable: true,
                recommendation: "Try eating your last meal 3 hours before bedtime for better sleep",
                confidence: 75
            )
        }
        
        return nil
    }
    
    private func generatePerformanceInsights() -> [SmartInsight] {
        var insights: [SmartInsight] = []
        
        // Exercise consistency
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let exercises = dataManager.getExercises(from: thirtyDaysAgo, to: Date())
        let exerciseDays = Set(exercises.map { 
            Calendar.current.startOfDay(for: $0.date) 
        }).count
        
        let totalDays = 30.0 // 30 days as we're using 30-day exercise data
        let consistency = Double(exerciseDays) / totalDays * 100
        
        if consistency > 70 {
            insights.append(SmartInsight(
                title: "Consistency Superstar",
                description: "You've exercised \(Int(consistency))% of days this month",
                impact: 25,
                category: .achievement,
                actionable: false,
                recommendation: nil,
                confidence: 90
            ))
        }
        
        return insights
    }
    
    private func generateBehavioralInsights() -> [SmartInsight] {
        var insights: [SmartInsight] = []
        
        // Weekly patterns  
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let exercises = dataManager.getExercises(from: thirtyDaysAgo, to: Date())
        let weekdayExercises = exercises.filter { 
            let weekday = Calendar.current.component(.weekday, from: $0.date)
            return weekday >= 2 && weekday <= 6 // Monday to Friday
        }
        
        let weekendExercises = exercises.filter {
            let weekday = Calendar.current.component(.weekday, from: $0.date)
            return weekday == 1 || weekday == 7 // Saturday and Sunday
        }
        
        if weekdayExercises.count > weekendExercises.count * 2 {
            insights.append(SmartInsight(
                title: "Weekday Warrior",
                description: "You exercise 3x more during weekdays than weekends",
                impact: 10,
                category: .correlation,
                actionable: true,
                recommendation: "Schedule lighter activities on weekends to maintain consistency",
                confidence: 80
            ))
        }
        
        return insights
    }
    
    private func generatePredictionInsights() -> [SmartInsight] {
        var insights: [SmartInsight] = []
        
        // Predict next likely missed day based on patterns
        let today = Calendar.current.component(.weekday, from: Date())
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        let recentExercises = dataManager.getExercises(from: twoWeeksAgo, to: Date())
        let todayExercises = recentExercises.filter {
            Calendar.current.component(.weekday, from: $0.date) == today
        }
        
        if todayExercises.isEmpty && today != 1 && today != 7 { // Not weekend
            insights.append(SmartInsight(
                title: "Workout Risk Alert",
                description: "You haven't exercised on a \(dayName(for: today)) in 2 weeks",
                impact: -15,
                category: .prediction,
                actionable: true,
                recommendation: "Schedule a 15-minute workout to break the pattern",
                confidence: 65
            ))
        }
        
        return insights
    }
    
    // MARK: - Trend Analysis
    func calculateTrends() -> [TrendData] {
        var trends: [TrendData] = []
        
        // Health score trend
        if let healthScoreTrend = calculateHealthScoreTrend() {
            trends.append(healthScoreTrend)
        }
        
        // Weight trend (if available)
        if let weightTrend = calculateWeightTrend() {
            trends.append(weightTrend)
        }
        
        // Exercise duration trend
        if let exerciseTrend = calculateExerciseTrend() {
            trends.append(exerciseTrend)
        }
        
        return trends
    }
    
    private func calculateHealthScoreTrend() -> TrendData? {
        let scores = weeklyScores.suffix(8) // Last 8 weeks
        guard scores.count > 3 else { return nil }
        
        let values = scores.map { $0.overall }
        let dates = scores.map { $0.date }
        
        let trend = determineTrendDirection(values: values)
        let velocity = calculateVelocity(values: values)
        let prediction = predictNextValue(values: values)
        
        return TrendData(
            metric: "Health Score",
            values: values,
            dates: dates,
            trend: trend,
            velocity: velocity,
            prediction: prediction
        )
    }
    
    private func calculateWeightTrend() -> TrendData? {
        // This would integrate with weight tracking if implemented
        return nil
    }
    
    private func calculateExerciseTrend() -> TrendData? {
        var weeklyDurations: [Double] = []
        var weekDates: [Date] = []
        
        for i in 0..<8 {
            let weekStart = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: Date()) ?? Date()
            let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? Date()
            
            let exercises = dataManager.getExercises(from: weekStart, to: weekEnd)
            let totalDuration = exercises.reduce(0) { $0 + $1.duration }
            
            weeklyDurations.append(totalDuration)
            weekDates.append(weekStart)
        }
        
        guard weeklyDurations.count > 3 else { return nil }
        
        let trend = determineTrendDirection(values: weeklyDurations)
        let velocity = calculateVelocity(values: weeklyDurations)
        let prediction = predictNextValue(values: weeklyDurations)
        
        return TrendData(
            metric: "Weekly Exercise Duration",
            values: weeklyDurations.reversed(),
            dates: weekDates.reversed(),
            trend: trend,
            velocity: velocity,
            prediction: prediction
        )
    }
    
    // MARK: - Helper Methods
    private func calculateCorrelation(data1: [Double], data2: [Double]) -> Double {
        guard data1.count == data2.count, !data1.isEmpty else { return 0 }
        
        let n = Double(data1.count)
        let sum1 = data1.reduce(0, +)
        let sum2 = data2.reduce(0, +)
        let sum1Sq = data1.reduce(0) { $0 + $1 * $1 }
        let sum2Sq = data2.reduce(0) { $0 + $1 * $1 }
        let pSum = zip(data1, data2).reduce(0) { $0 + $1.0 * $1.1 }
        
        let num = pSum - (sum1 * sum2 / n)
        let den = sqrt((sum1Sq - sum1 * sum1 / n) * (sum2Sq - sum2 * sum2 / n))
        
        return den == 0 ? 0 : num / den
    }
    
    private func determineTrendDirection(values: [Double]) -> TrendData.TrendDirection {
        guard values.count > 2 else { return .stable }
        
        let recent = values.suffix(3)
        let earlier = values.prefix(values.count - 2)
        
        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let earlierAvg = earlier.reduce(0, +) / Double(earlier.count)
        
        let change = (recentAvg - earlierAvg) / earlierAvg * 100
        
        if change > 5 { return .improving }
        else if change < -5 { return .declining }
        else if values.map({ abs($0 - recentAvg) }).max() ?? 0 > recentAvg * 0.2 { return .volatile }
        else { return .stable }
    }
    
    private func calculateVelocity(values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        
        let first = values.first ?? 0
        let last = values.last ?? 0
        let periods = Double(values.count - 1)
        
        return (last - first) / periods
    }
    
    private func predictNextValue(values: [Double]) -> Double? {
        guard values.count > 2 else { return nil }
        
        let velocity = calculateVelocity(values: values)
        let lastValue = values.last ?? 0
        
        return lastValue + velocity
    }
    
    private func dayName(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        
        let calendar = Calendar.current
        let date = calendar.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) ?? Date()
        
        return formatter.string(from: date)
    }
    
    // MARK: - Public Interface
    func calculateAnalytics() {
        isCalculating = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Calculate current health score
            let healthScore = self.calculateHealthScore()
            
            // Generate insights
            let insights = self.generateSmartInsights()
            
            // Calculate trends
            let trends = self.calculateTrends()
            
            // Calculate weekly scores for trend analysis
            var weeklyScores: [HealthScore] = []
            for i in 0..<8 {
                let date = Calendar.current.date(byAdding: .weekOfYear, value: -i, to: Date()) ?? Date()
                let score = self.calculateHealthScore(for: date)
                weeklyScores.append(score)
            }
            
            DispatchQueue.main.async {
                self.currentHealthScore = healthScore
                self.smartInsights = insights
                self.trends = trends
                self.weeklyScores = weeklyScores.reversed()
                self.isCalculating = false
            }
        }
    }
    
    func getWeeklyReport() -> AnalyticsReport {
        let healthScore = currentHealthScore ?? HealthScore()
        let predictions = trends.compactMap { trend -> String? in
            guard let prediction = trend.prediction else { return nil }
            return "\(trend.metric) predicted: \(String(format: "%.1f", prediction))"
        }
        
        let recommendations = smartInsights
            .filter { $0.actionable }
            .compactMap { $0.recommendation }
            .prefix(3)
            .map { String($0) }
        
        return AnalyticsReport(
            date: Date(),
            healthScore: healthScore,
            insights: smartInsights,
            trends: trends,
            predictions: predictions,
            recommendations: recommendations
        )
    }
}
