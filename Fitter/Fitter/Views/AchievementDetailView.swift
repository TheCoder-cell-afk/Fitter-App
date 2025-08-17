import SwiftUI

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    @State private var showCelebration = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Achievement header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: achievement.iconName)
                                .font(.system(size: 50))
                                .foregroundColor(.yellow)
                                .scaleEffect(showCelebration ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatCount(3), value: showCelebration)
                        }
                        
                        Text(achievement.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("🎉 Achievement Unlocked! 🎉")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    
                    // Achievement details
                    VStack(spacing: 20) {
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("What you accomplished")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(achievement.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        
                        // Motivation
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("Motivation")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(getMotivationText(for: achievement))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        
                        // Progress info
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundColor(.green)
                                Text("Your Progress")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            HStack {
                                Text("Goal:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(achievement.goal)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                            
                            HStack {
                                Text("Progress:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(achievement.progress)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        
                        // Celebration message
                        VStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.title)
                                .foregroundColor(.yellow)
                            
                            Text("Keep up the amazing work!")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Every achievement brings you closer to your health goals. You're building habits that will last a lifetime!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.yellow.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                showCelebration = true
            }
        }
    }
    
    private func getMotivationText(for achievement: Achievement) -> String {
        switch achievement.type {
        case .fastingTime:
            return "Your dedication to fasting shows incredible discipline and commitment to your health. Every hour of fasting is a step toward better metabolic health and increased energy levels. You're teaching your body to become more efficient at burning fat and improving insulin sensitivity."
        case .healthyEating:
            return "Making conscious choices about your nutrition is a powerful act of self-care. By tracking your meals and staying mindful of your nutrition, you're building sustainable habits that will support your long-term health goals. Every healthy meal is an investment in your future self."
        case .streak:
            return "Consistency is the key to lasting change, and you've proven that you have what it takes to stick with your goals. Building streaks creates momentum and helps establish healthy routines. Your commitment to showing up every day is truly inspiring!"
        case .appUsage:
            return "Your engagement with the app shows that you're actively taking control of your health journey. By regularly checking in and using the tools available, you're demonstrating a proactive approach to wellness. Every time you open the app, you're reinforcing your commitment to better health."
        case .exercise:
            return "Your commitment to regular exercise is building strength, endurance, and resilience. Every workout session is an investment in your physical and mental well-being. You're developing healthy habits that will support your long-term fitness goals and improve your overall quality of life."
        }
    }
} 