import Foundation
import UIKit

class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Chat Completion
    func sendChatMessage(_ message: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard APIConfig.isOpenAIConfigured else {
            completion(.failure(OpenAIError.apiKeyNotConfigured))
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        for (key, value) in APIConfig.openAIHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Create request body
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": message
                ]
            ],
            "max_tokens": 150,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to encode request"
            }
            completion(.failure(error))
            return
        }
        
        // Debug logging
        print("Sending request to: \(url.absoluteString)")
        print("Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")")
        
        // Send request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        let errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                        self?.errorMessage = errorMessage
                        completion(.failure(OpenAIError.httpError(httpResponse.statusCode)))
                        return
                    }
                }
                
                guard let data = data else {
                    let error = OpenAIError.noData
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    if let messageContent = response.choices.first?.message.content {
                        completion(.success(messageContent))
                    } else {
                        let error = OpenAIError.invalidResponse
                        self?.errorMessage = error.localizedDescription
                        completion(.failure(error))
                    }
                } catch {
                    // Log the raw response for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Raw OpenAI Response: \(responseString)")
                    }
                    self?.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Nutrition Analysis
    func analyzeNutrition(foodDescription: String, completion: @escaping (Result<NutritionAnalysis, Error>) -> Void) {
        let prompt = """
        Analyze the nutritional content of: "\(foodDescription)"
        
        Provide the following information:
        - Estimated calories per serving
        - Protein (grams)
        - Carbohydrates (grams)
        - Fat (grams)
        - Fiber (grams)
        - Sugar (grams)
        
        Format your response as JSON with keys: calories, protein, carbs, fat, fiber, sugar
        Only return the JSON, no additional text.
        """
        
        sendChatMessage(prompt) { result in
            switch result {
            case .success(let response):
                // Try to parse the JSON response
                if let data = response.data(using: .utf8),
                   let nutrition = try? JSONDecoder().decode(NutritionAnalysis.self, from: data) {
                    completion(.success(nutrition))
                } else {
                    completion(.failure(OpenAIError.invalidNutritionResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Vision API - Food Analysis
    func analyzeFoodImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard APIConfig.isOpenAIConfigured else {
            completion(.failure(OpenAIError.apiKeyNotConfigured))
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              let base64Image = imageData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            completion(.failure(OpenAIError.invalidImage))
            return
        }
        
        let url = URL(string: "\(APIConfig.openAIBaseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        for (key, value) in APIConfig.openAIHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Create request body for Vision API
        let requestBody: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": """
                            Analyze this food image and provide detailed nutritional information. 
                            Please provide:
                            1. What food items are visible
                            2. Estimated calories
                            3. Protein (grams)
                            4. Carbohydrates (grams)
                            5. Fat (grams)
                            6. Fiber (grams)
                            7. Sugar (grams)
                            8. Any health tips or recommendations
                            
                            Format your response in a clear, readable way.
                            """
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 500,
            "temperature": 0.3
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to encode request"
            }
            completion(.failure(error))
            return
        }
        
        // Send request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                // Check HTTP status code
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        let errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                        self?.errorMessage = errorMessage
                        completion(.failure(OpenAIError.httpError(httpResponse.statusCode)))
                        return
                    }
                }
                
                guard let data = data else {
                    let error = OpenAIError.noData
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    if let messageContent = response.choices.first?.message.content {
                        completion(.success(messageContent))
                    } else {
                        let error = OpenAIError.invalidResponse
                        self?.errorMessage = error.localizedDescription
                        completion(.failure(error))
                    }
                } catch {
                    // Log the raw response for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Raw Vision API Response: \(responseString)")
                    }
                    self?.errorMessage = "Failed to decode response"
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    // MARK: - Meal Suggestions
    func getMealSuggestions(for goal: String, calories: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        let prompt = """
        Suggest 3 healthy meals for someone with a \(goal) goal who wants to consume approximately \(calories) calories.
        
        Format your response as a JSON array of meal names only.
        Example: ["Grilled Chicken Salad", "Quinoa Bowl", "Salmon with Vegetables"]
        """
        
        sendChatMessage(prompt) { result in
            switch result {
            case .success(let response):
                if let data = response.data(using: .utf8),
                   let meals = try? JSONDecoder().decode([String].self, from: data) {
                    completion(.success(meals))
                } else {
                    completion(.failure(OpenAIError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Models
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}

struct NutritionAnalysis: Codable {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
}

// MARK: - Errors
enum OpenAIError: LocalizedError {
    case apiKeyNotConfigured
    case noData
    case invalidResponse
    case invalidNutritionResponse
    case invalidImage
    case httpError(Int)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "OpenAI API key is not configured"
        case .noData:
            return "No data received from OpenAI"
        case .invalidResponse:
            return "Invalid response from OpenAI"
        case .invalidNutritionResponse:
            return "Could not parse nutrition data from OpenAI response"
        case .invalidImage:
            return "Invalid image format or unable to process image"
        case .httpError(let statusCode):
            return "HTTP Error \(statusCode): \(httpErrorMessage(for: statusCode))"
        }
    }
    
    private func httpErrorMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 401:
            return "Invalid API key"
        case 429:
            return "Rate limit exceeded"
        case 500...599:
            return "Server error"
        default:
            return "Request failed"
        }
    }
}