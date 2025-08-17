import SwiftUI

struct ActivityView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var healthKitService: HealthKitService?
    @State private var stepsToday: Int = 0
    @State private var showExerciseLog = false
    @State private var animateContent = false
    @State private var showHealthKitPermission = false
    
    // Animation states
    @State private var logExerciseButtonScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    // Steps Card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .font(.title)
                                .foregroundColor(.blue)
                            Text("Today's Steps")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            Spacer()
                            
                            // HealthKit status indicator
                            if let service = healthKitService, service.isHealthKitAvailable {
                                Button(action: {
                                    if !service.isAuthorized {
                                        showHealthKitPermission = true
                                    }
                                }) {
                                    Image(systemName: service.isAuthorized ? "heart.fill" : "heart.slash")
                                        .font(.caption)
                                        .foregroundColor(service.isAuthorized ? .green : .red)
                                }
                            }
                        }
                        
                        if let service = healthKitService, service.isAuthorized {
                            HStack(alignment: .lastTextBaseline, spacing: 8) {
                                Text("\(service.dailySteps)")
                                    .font(.system(size: 48, weight: .heavy))
                                    .foregroundColor(.blue)
                                Text("steps")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Progress bar
                            let stepProgress = service.getDailyGoalProgress().steps
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Goal: 10,000 steps")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(stepProgress * 100))%")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                                
                                ProgressView(value: stepProgress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "heart.slash")
                                    .font(.system(size: 32))
                                    .foregroundColor(.red)
                                
                                Text("HealthKit Access Required")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Connect to HealthKit to see your step count")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Connect HealthKit") {
                                    showHealthKitPermission = true
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(.blue)
                                )
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 25)
                    
                    // Calories Burned Card
                    if let service = healthKitService, service.isAuthorized {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .font(.title)
                                    .foregroundColor(.orange)
                                Text("Calories Burned")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            HStack(alignment: .lastTextBaseline, spacing: 8) {
                                Text("\(Int(service.dailyCaloriesBurned))")
                                    .font(.system(size: 48, weight: .heavy))
                                    .foregroundColor(.orange)
                                Text("cal")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Progress bar
                            let calorieProgress = service.getDailyGoalProgress().calories
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Goal: 400 cal")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(calorieProgress * 100))%")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.orange)
                                }
                                
                                ProgressView(value: calorieProgress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                    }
                    
                    // Exercise Stats Card
                    exerciseStatsCard
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                    
                    // Weekly Activity Chart
                    if let service = healthKitService, service.isAuthorized {
                        weeklyActivityChart
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 35)
                    }
                    
                    // Exercise List
                    exerciseListSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGray6))
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Initialize HealthKit service safely
                if healthKitService == nil {
                    healthKitService = HealthKitService.shared
                }
                
                // Fetch HealthKit data safely
                if let service = healthKitService, service.isAuthorized {
                    service.fetchTodayData()
                    service.fetchWeeklyData()
                }
                
                withAnimation(.easeOut(duration: 0.8)) {
                    animateContent = true
                }
            }
            .sheet(isPresented: $showExerciseLog) {
                ExerciseLogView()
            }
            .sheet(isPresented: $showHealthKitPermission) {
                HealthKitPermissionView()
            }
        }
    }
    
    // MARK: - Computed Views
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activity")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Track your daily movement")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    logExerciseButtonScale = 0.9
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        logExerciseButtonScale = 1.0
                    }
                }
                showExerciseLog = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .scaleEffect(logExerciseButtonScale)
        }
        .padding(.top, 20)
    }
    
    private var exerciseStatsCard: some View {
        let stats = dataManager.getTodayExerciseStats()
        let totalMinutes = Int(stats.totalDuration / 60)
        
        return VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                Text("Today's Exercise")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("\(totalMinutes)")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(.blue)
                    Text("minutes")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text("\(stats.totalCalories)")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(.orange)
                    Text("calories")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text("\(dataManager.getTodayExercises().count)")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(.green)
                    Text("sessions")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var weeklyActivityChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Activity")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let service = healthKitService {
                    let weeklyAvg = service.getWeeklyAverage()
                    Text("Avg: \(weeklyAvg.steps) steps")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            // Weekly steps chart
            if let service = healthKitService {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0..<7, id: \.self) { index in
                        let daySteps = service.weeklySteps[index]
                        let maxSteps = service.weeklySteps.max() ?? 1
                        let height = maxSteps > 0 ? CGFloat(daySteps) / CGFloat(maxSteps) : 0
                    
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.blue)
                            .frame(width: 30, height: max(20, height * 120))
                            .animation(.easeInOut(duration: 0.5), value: height)
                        
                        Text("\(daySteps)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                                    }
                }
                .frame(height: 140)
                .padding(.top, 20)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var exerciseListSection: some View {
        let todayExercises = dataManager.getTodayExercises()
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Workouts")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !todayExercises.isEmpty {
                    Text("\(todayExercises.count) session\(todayExercises.count == 1 ? "" : "s")")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            if todayExercises.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("No exercises logged today")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Tap the + button to log your first workout")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(todayExercises) { exercise in
                        ExerciseCard(exercise: exercise) {
                            dataManager.removeExercise(exercise)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ActivityView()
} 