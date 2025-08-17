import SwiftUI

struct SimpleTutorial: View {
    @Binding var isShowing: Bool
    @State private var currentStep = 0
    @State private var animateFeature = false
    
    private let features = [
        FeatureHighlight(
            icon: "house.fill",
            title: "Home Dashboard",
            description: "Track your daily progress, current fasting status, and get quick insights",
            color: .blue
        ),
        FeatureHighlight(
            icon: "timer",
            title: "Smart Fasting",
            description: "Start, track, and log fasting sessions with real-time progress updates",
            color: .orange
        ),
        FeatureHighlight(
            icon: "camera.fill",
            title: "Food Tracking",
            description: "Take photos of meals for automatic calorie and nutrition tracking",
            color: .green
        ),
        FeatureHighlight(
            icon: "chart.bar.fill",
            title: "Analytics",
            description: "View detailed progress charts and health insights over time",
            color: .purple
        ),
        FeatureHighlight(
            icon: "rosette",
            title: "Achievements",
            description: "Earn XP, unlock achievements, and stay motivated with gamification",
            color: .yellow
        ),
        FeatureHighlight(
            icon: "function",
            title: "Health Calculators",
            description: "Calculate BMI, macros, and get AI-powered health recommendations",
            color: .cyan
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            VStack(spacing: 0) {
                // Header with skip button
                headerSection
                
                Spacer()
                
                // Feature highlight content
                featureContent
                
                Spacer()
                
                // Navigation controls
                navigationSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateFeature = true
            }
        }
        .onChange(of: currentStep) { _, _ in
            animateFeature = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.6)) {
                    animateFeature = true
                }
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.systemGray6).opacity(0.3),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            // Progress indicator
            Text("\(currentStep + 1) of \(features.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(.quaternary, lineWidth: 0.5)
                        )
                )
            
            Spacer()
            
            // Skip button
            Button("Skip") {
                isShowing = false
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(.quaternary, lineWidth: 0.5)
                    )
            )
        }
    }
    
    // MARK: - Feature Content
    private var featureContent: some View {
        let feature = features[currentStep]
        
        return VStack(spacing: 40) {
            // Feature icon with glow effect
            ZStack {
                // Background glow
                Circle()
                    .fill(feature.color.opacity(0.15))
                    .frame(width: 160, height: 160)
                    .blur(radius: 30)
                    .scaleEffect(animateFeature ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateFeature)
                
                // Icon container
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .stroke(feature.color.opacity(0.4), lineWidth: 2)
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: feature.color.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Icon
                Image(systemName: feature.icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(feature.color)
            }
            .opacity(animateFeature ? 1 : 0)
            .scaleEffect(animateFeature ? 1 : 0.8)
            .animation(.easeOut(duration: 0.6), value: animateFeature)
            
            // Feature details
            VStack(spacing: 20) {
                Text(feature.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .opacity(animateFeature ? 1 : 0)
                    .offset(y: animateFeature ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: animateFeature)
                
                Text(feature.description)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 20)
                    .opacity(animateFeature ? 1 : 0)
                    .offset(y: animateFeature ? 0 : 25)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: animateFeature)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Navigation Section
    private var navigationSection: some View {
        VStack(spacing: 20) {
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<features.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentStep ? features[currentStep].color : .secondary.opacity(0.3))
                        .frame(width: index == currentStep ? 10 : 6, height: index == currentStep ? 10 : 6)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            
            // Navigation buttons
            HStack(spacing: 20) {
                // Back button
                if currentStep > 0 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep -= 1
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(.quaternary, lineWidth: 0.5)
                                )
                        )
                    }
                }
                
                Spacer()
                
                // Next/Get Started button
                Button(action: {
                    if currentStep < features.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep += 1
                        }
                    } else {
                        isShowing = false
                    }
                }) {
                    HStack {
                        Text(currentStep < features.count - 1 ? "Next" : "Get Started")
                        if currentStep < features.count - 1 {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        features[currentStep].color,
                                        features[currentStep].color.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: features[currentStep].color.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
        }
    }
}

// MARK: - Feature Highlight Model
struct FeatureHighlight {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Preview
#Preview {
    SimpleTutorial(isShowing: .constant(true))
}
