import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    Text("Effective Date: July 27, 2025")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Fitter (\"we\", \"us\", or \"our\") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our app.")
                    Text("**Information We Collect**\n- Personal Information: When you create an account or use our app, we may collect information such as your name, email address, age, gender, height, weight, and activity level.\n- Health Data: With your permission, we may collect health-related data (e.g., fasting sessions, calorie intake) to provide personalized recommendations.\n- Usage Data: We may collect information about your device and how you use the app, such as device type, operating system, and app usage statistics.")
                    Text("**How We Use Your Information**\n- To provide and improve our services\n- To personalize your experience\n- To communicate with you about updates or offers\n- To comply with legal obligations")
                    Text("**How We Share Your Information**\n- We do not sell your personal information.\n- We may share information with service providers who help us operate the app.\n- We may disclose information if required by law or to protect our rights.")
                    Text("**Data Security**\nWe use reasonable measures to protect your information. However, no method of transmission over the Internet or electronic storage is 100% secure.")
                    Text("**Your Choices**\n- You can access and update your profile information in the app.\n- You can delete your account at any time by contacting support.")
                    Text("**Children’s Privacy**\nOur app is not intended for children under 13. We do not knowingly collect data from children under 13.")
                    Text("**Changes to This Policy**\nWe may update this Privacy Policy from time to time. We will notify you of any changes by updating the date at the top of this policy.")
                    Text("**Contact Us**\nIf you have any questions about this Privacy Policy, please contact us at [your support email].")
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PrivacyPolicyView()
} 