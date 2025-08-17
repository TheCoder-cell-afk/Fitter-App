import SwiftUI

struct CalculatorsView: View {
    @State private var animateContent = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    // Calculators Grid
                    calculatorsGrid
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 25)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGray6))
            .navigationTitle("Calculators")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateContent = true
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "function")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Health Calculators")
                .font(.title.bold())
            
            Text("Scientific calculators to support your health and fitness goals")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Calculators Grid
    private var calculatorsGrid: some View {
        VStack(spacing: 20) {
            // Main Calculators
            VStack(spacing: 16) {
                NavigationLink(destination: MacroCalculatorView()) {
                    CalculatorCard(
                        icon: "chart.pie.fill",
                        title: "Macro Calculator",
                        description: "Calculate your daily calorie and macronutrient needs using the Mifflin-St Jeor equation",
                        color: .blue,
                        features: ["BMR & TDEE", "Protein/Carbs/Fat", "Goal-based targets", "Activity adjustments"]
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: BMICalculatorView()) {
                    CalculatorCard(
                        icon: "person.fill",
                        title: "BMI Calculator",
                        description: "Calculate your Body Mass Index and get personalized health recommendations",
                        color: .green,
                        features: ["BMI calculation", "Health categories", "Weight recommendations", "Risk assessments"]
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Coming Soon Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 4)
                
                VStack(spacing: 12) {
                    ComingSoonCard(
                        icon: "heart.fill",
                        title: "Body Fat Calculator",
                        description: "Estimate body fat percentage using multiple methods"
                    )
                    
                    ComingSoonCard(
                        icon: "flame.fill",
                        title: "Calorie Burn Calculator",
                        description: "Calculate calories burned during different activities"
                    )
                    
                    ComingSoonCard(
                        icon: "drop.fill",
                        title: "Hydration Calculator",
                        description: "Determine your daily water intake needs"
                    )
                }
            }
        }
    }
}

struct CalculatorCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let features: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Features
            VStack(alignment: .leading, spacing: 8) {
                Text("Features:")
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], alignment: .leading, spacing: 8) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(color)
                            
                            Text(feature)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
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
}

struct ComingSoonCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Text("Soon")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.gray)
                .cornerRadius(6)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.02), radius: 5, x: 0, y: 2)
        )
        .opacity(0.7)
    }
}

#Preview {
    CalculatorsView()
}