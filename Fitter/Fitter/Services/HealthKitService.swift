import Foundation
import HealthKit
import Combine

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    @Published var dailySteps: Int = 0
    @Published var dailyCaloriesBurned: Double = 0
    @Published var weeklySteps: [Int] = Array(repeating: 0, count: 7)
    @Published var weeklyCalories: [Double] = Array(repeating: 0, count: 7)
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("❌ HealthKit is not available on this device")
            return
        }
        
        // Define the types of data we want to read - safely unwrap
        var typesToRead: Set<HKObjectType> = []
        
        if let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            typesToRead.insert(stepType)
        }
        if let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            typesToRead.insert(activeEnergyType)
        }
        if let basalEnergyType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned) {
            typesToRead.insert(basalEnergyType)
        }
        if let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) {
            typesToRead.insert(distanceType)
        }
        if let flightsType = HKObjectType.quantityType(forIdentifier: .flightsClimbed) {
            typesToRead.insert(flightsType)
        }
        
        // Only proceed if we have valid types
        guard !typesToRead.isEmpty else {
            print("❌ No valid HealthKit types available")
            return
        }
        
        // Request authorization
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    print("✅ HealthKit authorization granted")
                    self?.isAuthorized = true
                    // Fetch data safely after a delay to avoid crashes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.fetchTodayData()
                        self?.fetchWeeklyData()
                    }
                } else {
                    print("❌ HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                    self?.isAuthorized = false
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let caloriesType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("❌ HealthKit types not available")
            return
        }
        
        let stepStatus = healthStore.authorizationStatus(for: stepType)
        let caloriesStatus = healthStore.authorizationStatus(for: caloriesType)
        
        DispatchQueue.main.async {
            self.isAuthorized = (stepStatus == .sharingAuthorized && caloriesStatus == .sharingAuthorized)
            // Don't fetch data immediately to avoid crashes
        }
    }
    
    // MARK: - Data Fetching
    func fetchTodayData() {
        fetchTodaySteps()
        fetchTodayCalories()
    }
    
    private func fetchTodaySteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { 
            print("❌ Step type not available")
            return 
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let result = result, let sum = result.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: HKUnit.count()))
                    self?.dailySteps = steps
                    print("📱 Today's steps: \(steps)")
                } else {
                    print("❌ Failed to fetch steps: \(error?.localizedDescription ?? "Unknown error")")
                    // Set default value to prevent crashes
                    self?.dailySteps = 0
                }
            }
        }
        
        // Execute query
        healthStore.execute(query)
    }
    
    private func fetchTodayCalories() {
        guard let activeCaloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { 
            print("❌ Active calories type not available")
            return 
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: activeCaloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            DispatchQueue.main.async {
                if let result = result, let sum = result.sumQuantity() {
                    let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                    self?.dailyCaloriesBurned = calories
                    print("🔥 Today's calories burned: \(calories)")
                } else {
                    print("❌ Failed to fetch calories: \(error?.localizedDescription ?? "Unknown error")")
                    // Set default value to prevent crashes
                    self?.dailyCaloriesBurned = 0
                }
            }
        }
        
        // Execute query
        healthStore.execute(query)
    }
    
    // MARK: - Weekly Data
    func fetchWeeklyData() {
        fetchWeeklySteps()
        fetchWeeklyCalories()
    }
    
    private func fetchWeeklySteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        var weeklySteps: [Int] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
            
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let result = result, let sum = result.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: HKUnit.count()))
                    weeklySteps.append(steps)
                    
                    DispatchQueue.main.async {
                        if weeklySteps.count == 7 {
                            self.weeklySteps = weeklySteps
                        }
                    }
                } else {
                    weeklySteps.append(0)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    private func fetchWeeklyCalories() {
        guard let activeCaloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        var weeklyCalories: [Double] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
            
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: activeCaloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let result = result, let sum = result.sumQuantity() {
                    let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                    weeklyCalories.append(calories)
                    
                    DispatchQueue.main.async {
                        if weeklyCalories.count == 7 {
                            self.weeklyCalories = weeklyCalories
                        }
                    }
                } else {
                    weeklyCalories.append(0)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Data Writing
    func logExercise(name: String, duration: TimeInterval, calories: Double, steps: Int? = nil) {
        guard isAuthorized else {
            print("❌ HealthKit not authorized")
            return
        }
        
        // Log active energy burned
        if let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            let energyQuantity = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: calories)
            let energySample = HKQuantitySample(type: activeEnergyType, quantity: energyQuantity, start: Date().addingTimeInterval(-duration), end: Date())
            
            healthStore.save(energySample) { success, error in
                if success {
                    print("✅ Logged \(calories) calories to HealthKit")
                } else {
                    print("❌ Failed to log calories: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        // Log steps if provided
        if let steps = steps, let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            let stepQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: Double(steps))
            let stepSample = HKQuantitySample(type: stepType, quantity: stepQuantity, start: Date().addingTimeInterval(-duration), end: Date())
            
            healthStore.save(stepSample) { success, error in
                if success {
                    print("✅ Logged \(steps) steps to HealthKit")
                } else {
                    print("❌ Failed to log steps: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        // Refresh data after logging
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.fetchTodayData()
        }
    }
    
    // MARK: - Health Metrics
    func getDailyGoalProgress() -> (steps: Double, calories: Double) {
        let stepGoal = 10000.0
        let calorieGoal = 400.0
        
        let stepProgress = min(Double(dailySteps) / stepGoal, 1.0)
        let calorieProgress = min(dailyCaloriesBurned / calorieGoal, 1.0)
        
        return (stepProgress, calorieProgress)
    }
    
    func getWeeklyAverage() -> (steps: Int, calories: Double) {
        let avgSteps = weeklySteps.reduce(0, +) / weeklySteps.count
        let avgCalories = weeklyCalories.reduce(0, +) / Double(weeklyCalories.count)
        
        return (avgSteps, avgCalories)
    }
    
    // MARK: - Background Updates
    func startBackgroundUpdates() {
        guard isAuthorized else { return }
        
        // Set up background delivery for step count
        if let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
                if success {
                    print("✅ Background delivery enabled for steps")
                } else {
                    print("❌ Failed to enable background delivery: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        
        // Set up background delivery for active energy
        if let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            healthStore.enableBackgroundDelivery(for: energyType, frequency: .immediate) { success, error in
                if success {
                    print("✅ Background delivery enabled for calories")
                } else {
                    print("❌ Failed to enable background delivery: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    // MARK: - Health Status
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    var authorizationStatus: String {
        if !isHealthKitAvailable {
            return "HealthKit not available"
        } else if isAuthorized {
            return "Authorized"
        } else {
            return "Not authorized"
        }
    }
} 
