import SwiftUI

struct AnalyticsView: View {
    @StateObject private var analyticsService = AnalyticsService(dataManager: DataManager.shared)
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: MetricType = .overall
    @State private var showingDetailedReport = false
    
    // MARK: - Helper Functions
    private func calculateCurrentStreak() -> Int {
        let today = Date()
        let calendar = Calendar.current
        var streak = 0
        var currentDate = today
        
        // Check consecutive days with any activity
        while true {
            let dayStart = calendar.startOfDay(for: currentDate)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? currentDate
            
            let hasFood = !DataManager.shared.getFoods(from: dayStart, to: dayEnd).isEmpty
            let hasExercise = !DataManager.shared.getExercises(from: dayStart, to: dayEnd).isEmpty
            let hasWater = !DataManager.shared.getWaterEntries(from: dayStart, to: dayEnd).isEmpty
            
            if hasFood || hasExercise || hasWater {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateWorkoutCount() -> Int {
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? Date()
        
        return DataManager.shared.getExercises(from: weekStart, to: weekEnd).count
    }
    
    private func calculateBestDay() -> String {
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        var totalActivity = 0
        
        // Check if there's any meaningful activity data
        for i in 1...7 {
            let dayStart = Calendar.current.date(byAdding: .day, value: i-1, to: weekStart) ?? Date()
            let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? Date()
            
            let foodCount = DataManager.shared.getFoods(from: dayStart, to: dayEnd).count
            let exerciseCount = DataManager.shared.getExercises(from: dayStart, to: dayEnd).count
            let waterCount = DataManager.shared.getWaterEntries(from: dayStart, to: dayEnd).count
            
            totalActivity += foodCount + exerciseCount + waterCount
        }
        
        // If there's no meaningful activity data, return "N/A"
        if totalActivity == 0 {
            return "N/A"
        }
        
        // Only calculate best day if there's actual data
        var dayScores: [Int: Double] = [:]
        
        for i in 1...7 {
            let dayStart = Calendar.current.date(byAdding: .day, value: i-1, to: weekStart) ?? Date()
            let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) ?? Date()
            
            let foodCount = DataManager.shared.getFoods(from: dayStart, to: dayEnd).count
            let exerciseCount = DataManager.shared.getExercises(from: dayStart, to: dayEnd).count
            let waterCount = DataManager.shared.getWaterEntries(from: dayStart, to: dayEnd).count
            
            let score = Double(foodCount + exerciseCount + waterCount)
            dayScores[i] = score
        }
        
        let bestDay = dayScores.max(by: { $0.value < $1.value })?.key ?? 1
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let date = Calendar.current.date(byAdding: .day, value: bestDay - 1, to: weekStart) ?? Date()
        
        return formatter.string(from: date)
    }
    
    // MARK: - Computed Properties
    private var currentStreak: Int {
        calculateCurrentStreak()
    }
    
    private var workoutCount: Int {
        calculateWorkoutCount()
    }
    
    private var bestDay: String {
        calculateBestDay()
    }
    
    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case month = "30D"
        case quarter = "90D"
        case year = "1Y"
        
        var title: String {
            switch self {
            case .week: return "This Week"
            case .month: return "This Month"
            case .quarter: return "Last 3 Months"
            case .year: return "This Year"
            }
        }
    }
    
    enum MetricType: String, CaseIterable {
        case overall = "Overall"
        case nutrition = "Nutrition"
        case exercise = "Exercise"
        case hydration = "Hydration"
        case fasting = "Fasting"
    }
    
    var body: some View {
        NavigationView {
            if analyticsService.isCalculating {
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Calculating your analytics...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Health Score Dashboard
                        healthScoreDashboard
                        
                        // Time Range Selector
                        timeRangeSelector
                        
                        // Quick Insights
                        quickInsights
                        
                        // Trend Charts
                        trendCharts
                        
                        // Smart Insights
                        smartInsightsSection
                        
                        // Predictions
                        predictionsSection
                        
                        // Detailed Report Button
                        detailedReportButton
                    }
                    .padding()
                }
                .navigationTitle("Analytics")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $showingDetailedReport) {
                    AnalyticsReportView(analyticsService: analyticsService)
                }
                .refreshable {
                    analyticsService.calculateAnalytics()
                }
            }
        }
        .onAppear {
            if analyticsService.currentHealthScore == nil {
                analyticsService.calculateAnalytics()
            }
        }
    }
    
    // MARK: - Health Score Dashboard
    private var healthScoreDashboard: some View {
        VStack(spacing: 16) {
            Text("Health Score")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let currentScore = analyticsService.currentHealthScore {
                HStack(spacing: 20) {
                    // Overall Score Circle
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: currentScore.overall / 100)
                            .stroke(
                                LinearGradient(
                                    colors: [getScoreColor(currentScore.overall), getScoreColor(currentScore.overall).opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1), value: currentScore.overall)
                        
                        VStack(spacing: 2) {
                            Text("\(Int(currentScore.overall))")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(getScoreColor(currentScore.overall))
                            Text("Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        // Category Scores
                        ScoreRow(title: "Nutrition", score: currentScore.nutrition, color: .green)
                        ScoreRow(title: "Exercise", score: currentScore.activity, color: .blue)
                        ScoreRow(title: "Hydration", score: currentScore.hydration, color: .cyan)
                        ScoreRow(title: "Fasting", score: currentScore.fasting, color: .orange)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 160)
                    .overlay(
                        VStack {
                            ProgressView()
                            Text("Calculating health score...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Time Range Selector
    private var timeRangeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Range")
                .font(.headline)
                .fontWeight(.semibold)
            
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Quick Insights
    private var quickInsights: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week at a Glance")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                // Real streak data
                QuickInsightCard(
                    title: "Streak",
                    value: "\(currentStreak) days",
                    icon: "flame.fill",
                    color: .orange,
                    trend: currentStreak > 0 ? .up : .neutral
                )
                
                // Real workout count
                QuickInsightCard(
                    title: "Workouts",
                    value: "\(workoutCount)",
                    icon: "figure.run",
                    color: .blue,
                    trend: workoutCount > 0 ? .up : .neutral
                )
                
                // Real health score
                QuickInsightCard(
                    title: "Avg Score",
                    value: String(format: "%.0f", analyticsService.currentHealthScore?.overall ?? 0),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green,
                    trend: .stable
                )
                
                // Real best day
                QuickInsightCard(
                    title: "Best Day",
                    value: bestDay,
                    icon: "star.fill",
                    color: .yellow,
                    trend: .neutral
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Trend Charts
    private var trendCharts: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Trends")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Picker("Metric", selection: $selectedMetric) {
                    ForEach(MetricType.allCases, id: \.self) { metric in
                        Text(metric.rawValue).tag(metric)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.blue)
            }
            
            if !analyticsService.weeklyScores.isEmpty {
                // Simple line chart visualization
                VStack(spacing: 12) {
                    HStack {
                        ForEach(Array(analyticsService.weeklyScores.enumerated()), id: \.offset) { index, score in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(getMetricColor(selectedMetric))
                                    .frame(width: 20, height: CGFloat(getMetricValue(for: selectedMetric, from: score) * 2))
                                    .cornerRadius(4)
                                
                                Text("W\(index + 1)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 200)
                    
                    HStack {
                        Text("Score: 0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Score: 100")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No trend data available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Smart Insights
    private var smartInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Smart Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.purple)
            }
            
            if analyticsService.smartInsights.isEmpty {
                InsightPlaceholder()
            } else {
                ForEach(analyticsService.smartInsights.prefix(3), id: \.id) { insight in
                    SmartInsightCard(insight: insight)
                }
                
                if analyticsService.smartInsights.count > 3 {
                    Button("View All Insights") {
                        showingDetailedReport = true
                    }
                    .foregroundColor(.blue)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Predictions
    private var predictionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Predictions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "crystal.ball")
                    .foregroundColor(.cyan)
            }
            
            if analyticsService.trends.isEmpty {
                PredictionPlaceholder()
            } else {
                ForEach(analyticsService.trends.prefix(2), id: \.metric) { trend in
                    if let prediction = trend.prediction {
                        PredictionCard(
                            title: "Next Week \(trend.metric)",
                            prediction: prediction,
                            confidence: 75, // Mock confidence
                            trend: trend.trend
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Detailed Report Button
    private var detailedReportButton: some View {
        Button(action: {
            showingDetailedReport = true
        }) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                Text("View Detailed Report")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Methods
    private func getScoreColor(_ score: Double) -> Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .yellow
        case 40...59: return .orange
        default: return .red
        }
    }
    
    private func getMetricValue(for metric: MetricType, from score: HealthScore) -> Double {
        switch metric {
        case .overall: return score.overall
        case .nutrition: return score.nutrition
        case .exercise: return score.activity
        case .hydration: return score.hydration
        case .fasting: return score.fasting
        }
    }
    
    private func getMetricColor(_ metric: MetricType) -> Color {
        switch metric {
        case .overall: return .purple
        case .nutrition: return .green
        case .exercise: return .blue
        case .hydration: return .cyan
        case .fasting: return .orange
        }
    }
}

// MARK: - Supporting Views
struct ScoreRow: View {
    let title: String
    let score: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(Int(score))")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct QuickInsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: TrendDirection
    
    enum TrendDirection {
        case up, down, stable, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "arrow.right"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .stable: return .blue
            case .neutral: return .gray
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .foregroundColor(trend.color)
                    .font(.caption)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SmartInsightCard: View {
    let insight: SmartInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Confidence indicator
                HStack(spacing: 4) {
                    Image(systemName: "brain.head.profile")
                        .font(.caption2)
                    Text("\(Int(insight.confidence))%")
                        .font(.caption2)
                }
                .foregroundColor(.purple)
            }
            
            Text(insight.description)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            if let recommendation = insight.recommendation, insight.actionable {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text(recommendation)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 4)
            }
            
            // Impact indicator
            HStack {
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: insight.impact > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundColor(insight.impact > 0 ? .green : .red)
                        .font(.caption)
                    
                    Text("Impact: \(insight.impact > 0 ? "+" : "")\(Int(insight.impact))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(getCategoryColor(insight.category), lineWidth: 1)
                )
        )
    }
    
    private func getCategoryColor(_ category: SmartInsight.InsightCategory) -> Color {
        switch category {
        case .correlation: return .blue
        case .prediction: return .purple
        case .optimization: return .green
        case .warning: return .orange
        case .achievement: return .yellow
        }
    }
}

struct PredictionCard: View {
    let title: String
    let prediction: Double
    let confidence: Int
    let trend: TrendData.TrendDirection
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(String(format: "%.1f", prediction))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(getTrendColor(trend))
                
                HStack(spacing: 4) {
                    Image(systemName: "brain.head.profile")
                        .font(.caption2)
                    Text("\(confidence)% confident")
                        .font(.caption2)
                }
                .foregroundColor(.purple)
            }
            
            Spacer()
            
            Image(systemName: getTrendIcon(trend))
                .font(.title2)
                .foregroundColor(getTrendColor(trend))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func getTrendColor(_ trend: TrendData.TrendDirection) -> Color {
        switch trend {
        case .improving: return .green
        case .declining: return .red
        case .stable: return .blue
        case .volatile: return .orange
        }
    }
    
    private func getTrendIcon(_ trend: TrendData.TrendDirection) -> String {
        switch trend {
        case .improving: return "arrow.up.right.circle.fill"
        case .declining: return "arrow.down.right.circle.fill"
        case .stable: return "arrow.right.circle.fill"
        case .volatile: return "arrow.up.and.down.circle.fill"
        }
    }
}

struct InsightPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("Building insights...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Use the app for a few days to unlock personalized insights")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PredictionPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "crystal.ball")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("Generating predictions...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("More data needed for accurate predictions")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Analytics Report View
struct AnalyticsReportView: View {
    let analyticsService: AnalyticsService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Report Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Health Report")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Generated on \(Date().formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Detailed Insights
                    VStack(alignment: .leading, spacing: 16) {
                        Text("All Insights")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ForEach(analyticsService.smartInsights, id: \.id) { insight in
                            SmartInsightCard(insight: insight)
                        }
                    }
                    .padding()
                    
                    // Trends Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Trend Analysis")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ForEach(analyticsService.trends, id: \.metric) { trend in
                            TrendDetailCard(trend: trend)
                        }
                    }
                    .padding()
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Detailed Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TrendDetailCard: View {
    let trend: TrendData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(trend.metric)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Trend")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: getTrendIcon(trend.trend))
                            .foregroundColor(getTrendColor(trend.trend))
                        Text(getTrendDescription(trend.trend))
                            .font(.footnote)
                    }
                }
                
                Spacer()
                
                if let prediction = trend.prediction {
                    VStack(alignment: .trailing) {
                        Text("Predicted")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.1f", prediction))
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func getTrendColor(_ trend: TrendData.TrendDirection) -> Color {
        switch trend {
        case .improving: return .green
        case .declining: return .red
        case .stable: return .blue
        case .volatile: return .orange
        }
    }
    
    private func getTrendIcon(_ trend: TrendData.TrendDirection) -> String {
        switch trend {
        case .improving: return "arrow.up.right"
        case .declining: return "arrow.down.right"
        case .stable: return "arrow.right"
        case .volatile: return "arrow.up.and.down"
        }
    }
    
    private func getTrendDescription(_ trend: TrendData.TrendDirection) -> String {
        switch trend {
        case .improving: return "Improving"
        case .declining: return "Declining"
        case .stable: return "Stable"
        case .volatile: return "Volatile"
        }
    }
    
}

#Preview {
    AnalyticsView()
}