import SwiftUI

@main
struct FitterApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var authManager = AuthManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasShownTutorial") private var hasShownTutorial: Bool = false
    @State private var healthKitService: HealthKitService?
    @State private var showingTutorial = false

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                if hasCompletedOnboarding {
                    MainTabView()
                        .environmentObject(authManager)
                        .onAppear {
                            notificationManager.requestNotificationPermission()
                            DataManager.shared.updateAchievements(for: .appUsage)
                            if !hasShownTutorial {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showingTutorial = true
                                }
                            }
                        }
                        .overlay {
                            if showingTutorial {
                                ZStack {
                                    Color.black.opacity(0.85) // <--- Increased opacity for stronger dim
                                        .ignoresSafeArea()
                                    SimpleTutorial(isShowing: $showingTutorial)
                                        .onDisappear {
                                            hasShownTutorial = true
                                        }
                                }
                            }
                        }
                        .onAppear {
                            if healthKitService == nil {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    healthKitService = HealthKitService.shared
                                }
                            }
                        }
                } else {
                    OnboardingView()
                        .environmentObject(authManager)
                        .onAppear {
                            notificationManager.requestNotificationPermission()
                        }
                }
            } else {
                SignInView()
                    .environmentObject(authManager)
            }
        }
    }
}
