import SwiftUI

struct AIAssistantView: View {
    @StateObject private var openAIService = OpenAIService.shared
    @State private var userInput = ""
    @State private var response = ""
    @State private var showingNutritionAnalysis = false
    @State private var showingFoodCamera = false
    @State private var nutritionAnalysis: NutritionAnalysis?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("AI Assistant")
                            .font(.title.bold())
                        
                        Text("Ask questions about nutrition, get meal suggestions, or analyze foods")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // API Key Status
                    HStack {
                        Image(systemName: APIConfig.isOpenAIConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(APIConfig.isOpenAIConfigured ? .green : .orange)
                        
                        Text(APIConfig.isOpenAIConfigured ? "OpenAI API Key Configured" : "Configure API Key in APIConfig.swift")
                            .font(.caption)
                            .foregroundColor(APIConfig.isOpenAIConfigured ? .green : .orange)
                    }
                    .padding(.horizontal)
                    
                    // Coming Soon Message
                    VStack(spacing: 20) {
                        Image(systemName: "clock.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Coming Soon!")
                            .font(.title.bold())
                            .foregroundColor(.primary)
                        
                        Text("Our AI Assistant is currently in development. Soon you'll be able to:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "brain.head.profile", text: "Ask nutrition questions")
                            FeatureRow(icon: "camera.fill", text: "Analyze food photos")
                            FeatureRow(icon: "lightbulb.fill", text: "Get personalized meal suggestions")
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Track your progress with AI insights")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        Text("We're working hard to bring you the best AI-powered fitness experience!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    // Hidden: Original AI Interface (preserved for future use)
                    if false && APIConfig.isOpenAIConfigured {
                        // Chat Interface
                        VStack(spacing: 16) {
                            // Input Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ask your question:")
                                    .font(.headline)
                                
                                TextField("e.g., How many calories in a banana?", text: $userInput, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .lineLimit(3...6)
                            }
                            
                            // Action Buttons
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    Button("Send Question") {
                                        sendQuestion()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(userInput.isEmpty || openAIService.isLoading)
                                    
                                    Button("Analyze Food") {
                                        analyzeNutrition()
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(userInput.isEmpty || openAIService.isLoading)
                                }
                                
                                Button("📷 Analyze Food Photo") {
                                    showingFoodCamera = true
                                }
                                .buttonStyle(.borderedProminent)
                                .foregroundColor(.green)
                            }
                            
                            // Loading State
                            if openAIService.isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Thinking...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            
                            // Error Message
                            if let errorMessage = openAIService.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // Response
                            if !response.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("AI Response:")
                                        .font(.headline)
                                    
                                    Text(response)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                            }
                            
                            // Nutrition Analysis
                            if let nutrition = nutritionAnalysis {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Nutrition Analysis:")
                                        .font(.headline)
                                    
                                    VStack(spacing: 8) {
                                        NutritionRow(label: "Calories", value: "\(nutrition.calories)")
                                        NutritionRow(label: "Protein", value: String(format: "%.1f", nutrition.protein) + "g")
                                        NutritionRow(label: "Carbs", value: String(format: "%.1f", nutrition.carbs) + "g")
                                        NutritionRow(label: "Fat", value: String(format: "%.1f", nutrition.fat) + "g")
                                        NutritionRow(label: "Fiber", value: String(format: "%.1f", nutrition.fiber) + "g")
                                        NutritionRow(label: "Sugar", value: String(format: "%.1f", nutrition.sugar) + "g")
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 2)
                            }
                        }
                        .padding()
                    } else if false {
                        // Configuration Instructions
                        VStack(spacing: 16) {
                            Text("To use the AI Assistant:")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("1. Open Fitter/Config/APIConfig.swift")
                                Text("2. Replace 'YOUR_ACTUAL_OPENAI_API_KEY' with your real API key")
                                Text("3. Your API key should start with 'sk-'")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingFoodCamera) {
                FoodCameraView()
            }
        }
    }
    
    private func sendQuestion() {
        openAIService.sendChatMessage(userInput) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let aiResponse):
                    self.response = aiResponse
                    self.nutritionAnalysis = nil // Clear nutrition analysis when showing general response
                case .failure(let error):
                    self.response = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func analyzeNutrition() {
        openAIService.analyzeNutrition(foodDescription: userInput) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let analysis):
                    self.nutritionAnalysis = analysis
                    self.response = "" // Clear general response when showing nutrition analysis
                case .failure(let error):
                    self.response = "Nutrition analysis error: \(error.localizedDescription)"
                    self.nutritionAnalysis = nil
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct NutritionRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
        }
    }
}

#Preview {
    AIAssistantView()
}