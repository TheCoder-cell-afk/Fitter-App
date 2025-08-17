import SwiftUI

// MARK: - iOS 26 Ready
// This TabView will automatically get Liquid Glass on iOS 26:
// ✅ Liquid Glass tab bars that float above content
// ✅ New control interaction effects when switching tabs
// ✅ Automatic minimization on scroll for more content space
// ✅ Glass appearance against content underneath
// ✅ Enhanced visual hierarchy and separation

struct MainTabView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            FastingView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Fasting")
                }
                .tag(1)
            
            CaloriesView()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Calories")
                }
                .tag(2)
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
                .tag(3)
            
            GamificationView()
                .tabItem {
                    Image(systemName: "rosette")
                    Text("Progress")
                }
                .tag(4)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(5)
            
            CalculatorsView()
                .tabItem {
                    Image(systemName: "function")
                    Text("Calculators")
                }
                .tag(6)
            
            AIAssistantView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AI Assistant")
                }
                .tag(7)
            
            ActivityView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Activity")
                }
                .tag(8)
            

        }
        .accentColor(.blue)
        // iOS 26 Ready: Tab bar will automatically get Liquid Glass
        // These features will enhance the Liquid Glass experience
        .onReceive(NotificationCenter.default.publisher(for: .init("NavigateToCalories"))) { _ in
            selectedTab = 2
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("ShowAddFood"))) { _ in
            selectedTab = 2
            // Post another notification to show add food sheet
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NotificationCenter.default.post(name: .init("ShowAddFoodSheet"), object: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("NavigateToProfile"))) { _ in
            selectedTab = 5 // Navigate to Profile tab
        }
    }
}

#Preview {
    MainTabView()
} 