import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showOnboarding = false
    @State private var guestButtonScale: CGFloat = 1.0
    @State private var showTermsSheet = false
    @State private var showPrivacySheet = false
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack {
                Spacer(minLength: 60)
                
                // Card
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "timer")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Fitter")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Your fasting companion")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("Continue as guest to get started quickly with your health journey")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                    
                    // Continue as Guest button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            guestButtonScale = 0.96
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                guestButtonScale = 1.0
                            }
                        }
                        authManager.signInAsGuest()
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.title3)
                            Text("Continue as Guest")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        )
                        .cornerRadius(10)
                        .shadow(color: .orange.opacity(0.15), radius: 6, x: 0, y: 3)
                    }
                    .scaleEffect(guestButtonScale)
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 4)
                    
                    // Privacy notice with tappable links
                    HStack(spacing: 4) {
                        Text("By signing in, you agree to our")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Button(action: { showTermsSheet = true }) {
                            Text("Terms of Service")
                                .underline()
                                .font(.caption2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Text("and")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Button(action: { showPrivacySheet = true }) {
                            Text("Privacy Policy")
                                .underline()
                                .font(.caption2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
                )
                .padding(.horizontal, 24)
                
                Spacer(minLength: 60)
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showTermsSheet) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyPolicyView()
        }

    }
    

}

#Preview {
    SignInView()
} 