import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Terms of Service")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    Text("Effective Date: July 27, 2025")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Welcome to Fitter! By using our app, you agree to these Terms of Service (\"Terms\"). Please read them carefully.")
                    Text("**Use of the App**\n- You must be at least 13 years old to use Fitter.\n- You agree to use the app only for lawful purposes and in accordance with these Terms.")
                    Text("**Accounts**\n- You are responsible for maintaining the confidentiality of your account information.\n- You agree to provide accurate and complete information when creating your account.")
                    Text("**Health Disclaimer**\n- Fitter is intended for informational and motivational purposes only.\n- Always consult with a healthcare professional before making changes to your diet or exercise routine.\n- We are not responsible for any health issues that may result from using the app.")
                    Text("**Intellectual Property**\n- All content and materials in the app are owned by Fitter or its licensors.\n- You may not copy, modify, distribute, or create derivative works without our permission.")
                    Text("**Termination**\n- We may suspend or terminate your access to the app at any time for any reason, including violation of these Terms.")
                    Text("**Limitation of Liability**\n- Fitter is provided “as is” without warranties of any kind.\n- We are not liable for any damages arising from your use of the app.")
                    Text("**Changes to These Terms**\nWe may update these Terms from time to time. Continued use of the app after changes means you accept the new Terms.")
                    Text("**Contact Us**\nIf you have any questions about these Terms, please contact us at [your support email].")
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
    TermsOfServiceView()
} 