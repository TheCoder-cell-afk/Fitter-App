import SwiftUI

struct MoreView: View {
    @State private var animateContent = false
    @State private var showingTutorial = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Account Section
                    accountSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    // Tools Section
                    toolsSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                    
                    // Health & Fitness Section
                    healthFitnessSection
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 35)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGray6))
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateContent = true
                }
            }
        }
        .overlay {
            if showingTutorial {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    SimpleTutorial(isShowing: $showingTutorial)
                }
            }
        }
    }
    

    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account & Settings")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                NavigationLink(destination: ProfileView()) {
                    MoreItemCard(
                        icon: "person.fill",
                        title: "Profile & Settings",
                        description: "Manage your account, preferences, and app settings",
                        color: .blue
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Tools Section
    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Tools")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                NavigationLink(destination: CalculatorsView()) {
                    MoreItemCard(
                        icon: "function",
                        title: "Health Calculators",
                        description: "BMI calculator and macro nutrition calculator",
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: AIAssistantView()) {
                    MoreItemCard(
                        icon: "brain.head.profile",
                        title: "AI Assistant",
                        description: "Ask questions about nutrition and get meal suggestions",
                        color: .purple,
                        badge: APIConfig.isOpenAIConfigured ? nil : "Setup Required"
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    showingTutorial = true
                }) {
                    MoreItemCard(
                        icon: "questionmark.circle.fill",
                        title: "App Tutorial",
                        description: "Learn about the most important features and how to use them",
                        color: .orange
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Health & Fitness Section
    private var healthFitnessSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health & Fitness")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                NavigationLink(destination: ActivityView()) {
                    MoreItemCard(
                        icon: "figure.walk",
                        title: "Activity Tracker",
                        description: "Log your exercises and track your daily movement",
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())
                

                
                NavigationLink(destination: WaterTrackerView()) {
                    MoreItemCard(
                        icon: "drop.fill",
                        title: "Water Tracker",
                        description: "Track your daily water intake and stay hydrated",
                        color: .cyan
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct MoreItemCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let badge: String?
    
    init(icon: String, title: String, description: String, color: Color, badge: String? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
        self.color = color
        self.badge = badge
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let badge = badge {
                        Text(badge)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

// ...rest of MoreView (unchanged)...
