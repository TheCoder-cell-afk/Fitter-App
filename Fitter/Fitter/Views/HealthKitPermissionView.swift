import SwiftUI

struct HealthKitPermissionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var healthKitService = HealthKitService.shared
    @State private var isRequesting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.red)
                    
                    Text("Connect to HealthKit")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Fitter can help you track your health data more accurately by connecting to Apple Health")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Benefits
                VStack(alignment: .leading, spacing: 16) {
                    Text("What you'll get:")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        BenefitRow(
                            icon: "figure.walk",
                            title: "Step Count",
                            description: "Automatic step tracking from your iPhone and Apple Watch"
                        )
                        
                        BenefitRow(
                            icon: "flame.fill",
                            title: "Calories Burned",
                            description: "Active and passive calorie burn data"
                        )
                        
                        BenefitRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Activity Trends",
                            description: "Weekly and monthly activity insights"
                        )
                        
                        BenefitRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Sync Across Devices",
                            description: "Your data stays in sync with Apple Health"
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: requestHealthKitAccess) {
                        HStack {
                            if isRequesting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            Text(isRequesting ? "Connecting..." : "Connect HealthKit")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(.blue)
                        )
                    }
                    .disabled(isRequesting)
                    
                    Button("Not Now") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
        .alert("HealthKit Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func requestHealthKitAccess() {
        isRequesting = true
        
        healthKitService.requestAuthorization()
        
        // Check authorization status after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isRequesting = false
            
            if healthKitService.isAuthorized {
                dismiss()
            } else {
                errorMessage = "Failed to get HealthKit access. Please check your settings and try again."
                showError = true
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    HealthKitPermissionView()
} 