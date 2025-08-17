import Foundation

struct APIConfig {
    // MARK: - OpenAI Configuration
    // ⚠️ IMPORTANT: Replace with your own API key before building
    // Get your API key from: https://platform.openai.com/api-keys
    static let openAIAPIKey = "your_openai_api_key_here"
    static let openAIBaseURL = "https://api.openai.com/v1"
    
    // MARK: - USDA Configuration
    // Using DEMO_KEY for immediate testing - works out of the box!
    // For production use, get your own API key from: https://fdc.nal.usda.gov/api-key-signup.html
    static let usdaAPIKey = "DEMO_KEY"
    static let usdaBaseURL = "https://api.nal.usda.gov/fdc/v1"
    
    // MARK: - API Headers
    static var openAIHeaders: [String: String] {
        return [
            "Authorization": "Bearer \(openAIAPIKey)",
            "Content-Type": "application/json"
        ]
    }
    
    // MARK: - Validation
    static var isOpenAIConfigured: Bool {
        return !openAIAPIKey.isEmpty && openAIAPIKey.hasPrefix("sk-") && openAIAPIKey != "your_openai_api_key_here"
    }
    
    static var isUSDAConfigured: Bool {
        return !usdaAPIKey.isEmpty && usdaAPIKey != "your_usda_api_key_here"
    }
}