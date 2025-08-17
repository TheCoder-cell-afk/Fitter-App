import Foundation
import Combine

class NutritionAPIService: ObservableObject {
    static let shared = NutritionAPIService()
    
    // USDA Food Database API
    private let baseURL = APIConfig.usdaBaseURL
    private let apiKey = APIConfig.usdaAPIKey
    
    @Published var searchResults: [FoodItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Enhanced Food Search with Local Database
    func searchFood(query: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // First, search local database for popular foods
        let localResults = searchLocalDatabase(query: query.lowercased())
        
        // Then search USDA API
        let usdaResults = await searchUSDADatabase(query: query)
        
        await MainActor.run {
            // Combine results, prioritizing local database for common foods
            var combinedResults = localResults
            
            // Add USDA results that aren't already in local results
            for usdaFood in usdaResults {
                let isDuplicate = localResults.contains { localFood in
                    localFood.name.lowercased().contains(usdaFood.name.lowercased()) ||
                    usdaFood.name.lowercased().contains(localFood.name.lowercased())
                }
                
                if !isDuplicate {
                    combinedResults.append(usdaFood)
                }
            }
            
            // Limit to 25 results and sort by relevance
            self.searchResults = Array(combinedResults.prefix(25))
            self.isLoading = false
        }
    }
    
    // MARK: - Local Food Database
    private func searchLocalDatabase(query: String) -> [FoodItem] {
        let allFoods = getLocalFoodDatabase()
        let queryWords = query.lowercased().split(separator: " ")
        
        return allFoods.filter { food in
            let foodName = food.name.lowercased()
            let brandName = food.brandOwner?.lowercased() ?? ""
            
            // Check if all query words are found in either name or brand
            let allWordsMatch = queryWords.allSatisfy { word in
                foodName.contains(word) || brandName.contains(word)
            }
            
            // Also check for exact matches
            let exactMatch = foodName.contains(query) || brandName.contains(query)
            
            return allWordsMatch || exactMatch
        }.sorted { first, second in
            // Prioritize exact matches and brand matches
            let firstExact = first.name.lowercased().contains(query) || (first.brandOwner?.lowercased().contains(query) ?? false)
            let secondExact = second.name.lowercased().contains(query) || (second.brandOwner?.lowercased().contains(query) ?? false)
            
            if firstExact && !secondExact {
                return true
            } else if !firstExact && secondExact {
                return false
            } else {
                // If both are exact or both are not, sort by name
                return first.name < second.name
            }
        }
    }
    
    private func getLocalFoodDatabase() -> [FoodItem] {
        return [
            // Burger King Items
            FoodItem(
                name: "Whopper",
                brandOwner: "Burger King",
                calories: 660,
                protein: 28.0,
                carbs: 49.0,
                fat: 40.0,
                fiber: 2.0,
                sodium: 980.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Whopper Jr.",
                brandOwner: "Burger King",
                calories: 310,
                protein: 12.0,
                carbs: 28.0,
                fat: 16.0,
                fiber: 1.0,
                sodium: 480.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Double Whopper",
                brandOwner: "Burger King",
                calories: 900,
                protein: 45.0,
                carbs: 49.0,
                fat: 58.0,
                fiber: 2.0,
                sodium: 1380.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Bacon King",
                brandOwner: "Burger King",
                calories: 1150,
                protein: 58.0,
                carbs: 49.0,
                fat: 82.0,
                fiber: 2.0,
                sodium: 1820.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Chicken Royale",
                brandOwner: "Burger King",
                calories: 360,
                protein: 16.0,
                carbs: 35.0,
                fat: 16.0,
                fiber: 1.0,
                sodium: 750.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Chicken Fries (8 pieces)",
                brandOwner: "Burger King",
                calories: 280,
                protein: 12.0,
                carbs: 28.0,
                fat: 14.0,
                fiber: 1.0,
                sodium: 720.0,
                fdcId: 0
            ),
            
            // McDonald's Items
            FoodItem(
                name: "Big Mac",
                brandOwner: "McDonald's",
                calories: 550,
                protein: 25.0,
                carbs: 45.0,
                fat: 30.0,
                fiber: 3.0,
                sodium: 950.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Quarter Pounder with Cheese",
                brandOwner: "McDonald's",
                calories: 520,
                protein: 30.0,
                carbs: 42.0,
                fat: 26.0,
                fiber: 2.0,
                sodium: 1100.0,
                fdcId: 0
            ),
            FoodItem(
                name: "McDouble",
                brandOwner: "McDonald's",
                calories: 400,
                protein: 22.0,
                carbs: 33.0,
                fat: 19.0,
                fiber: 2.0,
                sodium: 850.0,
                fdcId: 0
            ),
            FoodItem(
                name: "McChicken",
                brandOwner: "McDonald's",
                calories: 400,
                protein: 14.0,
                carbs: 39.0,
                fat: 21.0,
                fiber: 2.0,
                sodium: 650.0,
                fdcId: 0
            ),
            
            // Wendy's Items
            FoodItem(
                name: "Dave's Single",
                brandOwner: "Wendy's",
                calories: 570,
                protein: 26.0,
                carbs: 39.0,
                fat: 34.0,
                fiber: 2.0,
                sodium: 1110.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Dave's Double",
                brandOwner: "Wendy's",
                calories: 890,
                protein: 48.0,
                carbs: 39.0,
                fat: 58.0,
                fiber: 2.0,
                sodium: 1580.0,
                fdcId: 0
            ),
            
            // Common Foods
            FoodItem(
                name: "Chicken Breast (grilled)",
                brandOwner: nil,
                calories: 165,
                protein: 31.0,
                carbs: 0.0,
                fat: 3.6,
                fiber: 0.0,
                sodium: 74.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Salmon (baked)",
                brandOwner: nil,
                calories: 208,
                protein: 25.0,
                carbs: 0.0,
                fat: 12.0,
                fiber: 0.0,
                sodium: 59.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Brown Rice (cooked)",
                brandOwner: nil,
                calories: 216,
                protein: 4.5,
                carbs: 45.0,
                fat: 1.8,
                fiber: 3.5,
                sodium: 10.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Broccoli (steamed)",
                brandOwner: nil,
                calories: 55,
                protein: 3.7,
                carbs: 11.0,
                fat: 0.6,
                fiber: 5.2,
                sodium: 64.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Banana (medium)",
                brandOwner: nil,
                calories: 105,
                protein: 1.3,
                carbs: 27.0,
                fat: 0.4,
                fiber: 3.1,
                sodium: 1.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Apple (medium)",
                brandOwner: nil,
                calories: 95,
                protein: 0.5,
                carbs: 25.0,
                fat: 0.3,
                fiber: 4.4,
                sodium: 2.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Greek Yogurt (plain)",
                brandOwner: nil,
                calories: 130,
                protein: 22.0,
                carbs: 9.0,
                fat: 0.5,
                fiber: 0.0,
                sodium: 50.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Egg (large)",
                brandOwner: nil,
                calories: 70,
                protein: 6.0,
                carbs: 0.6,
                fat: 5.0,
                fiber: 0.0,
                sodium: 70.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Oatmeal (cooked)",
                brandOwner: nil,
                calories: 150,
                protein: 6.0,
                carbs: 27.0,
                fat: 3.0,
                fiber: 4.0,
                sodium: 115.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Almonds (1/4 cup)",
                brandOwner: nil,
                calories: 160,
                protein: 6.0,
                carbs: 6.0,
                fat: 14.0,
                fiber: 3.5,
                sodium: 0.0,
                fdcId: 0
            ),
            
            // More Popular Fast Food Items
            FoodItem(
                name: "Chicken Nuggets (6 pieces)",
                brandOwner: "McDonald's",
                calories: 250,
                protein: 14.0,
                carbs: 15.0,
                fat: 15.0,
                fiber: 1.0,
                sodium: 540.0,
                fdcId: 0
            ),
            FoodItem(
                name: "French Fries (medium)",
                brandOwner: "McDonald's",
                calories: 340,
                protein: 4.0,
                carbs: 44.0,
                fat: 16.0,
                fiber: 4.0,
                sodium: 230.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Chicken Sandwich",
                brandOwner: "Chick-fil-A",
                calories: 440,
                protein: 28.0,
                carbs: 41.0,
                fat: 19.0,
                fiber: 2.0,
                sodium: 1350.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Spicy Chicken Sandwich",
                brandOwner: "Chick-fil-A",
                calories: 450,
                protein: 28.0,
                carbs: 41.0,
                fat: 20.0,
                fiber: 2.0,
                sodium: 1400.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Classic Chicken Sandwich",
                brandOwner: "Popeyes",
                calories: 700,
                protein: 28.0,
                carbs: 49.0,
                fat: 42.0,
                fiber: 2.0,
                sodium: 1440.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Spicy Chicken Sandwich",
                brandOwner: "Popeyes",
                calories: 720,
                protein: 28.0,
                carbs: 49.0,
                fat: 44.0,
                fiber: 2.0,
                sodium: 1480.0,
                fdcId: 0
            ),
            
            // Healthy Options
            FoodItem(
                name: "Grilled Chicken Salad",
                brandOwner: "Chick-fil-A",
                calories: 320,
                protein: 37.0,
                carbs: 8.0,
                fat: 14.0,
                fiber: 4.0,
                sodium: 1050.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Grilled Chicken Wrap",
                brandOwner: "Subway",
                calories: 350,
                protein: 25.0,
                carbs: 35.0,
                fat: 12.0,
                fiber: 3.0,
                sodium: 800.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Turkey Breast Sandwich",
                brandOwner: "Subway",
                calories: 280,
                protein: 18.0,
                carbs: 45.0,
                fat: 3.5,
                fiber: 4.0,
                sodium: 820.0,
                fdcId: 0
            ),
            
            // Beverages
            FoodItem(
                name: "Coca-Cola (12 oz)",
                brandOwner: "Coca-Cola",
                calories: 140,
                protein: 0.0,
                carbs: 39.0,
                fat: 0.0,
                fiber: 0.0,
                sodium: 45.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Diet Coke (12 oz)",
                brandOwner: "Coca-Cola",
                calories: 0,
                protein: 0.0,
                carbs: 0.0,
                fat: 0.0,
                fiber: 0.0,
                sodium: 40.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Orange Juice (8 oz)",
                brandOwner: nil,
                calories: 110,
                protein: 1.7,
                carbs: 26.0,
                fat: 0.5,
                fiber: 0.5,
                sodium: 2.0,
                fdcId: 0
            ),
            
            // Snacks
            FoodItem(
                name: "Potato Chips (1 oz)",
                brandOwner: "Lay's",
                calories: 150,
                protein: 2.0,
                carbs: 15.0,
                fat: 10.0,
                fiber: 1.0,
                sodium: 170.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Popcorn (air-popped, 3 cups)",
                brandOwner: nil,
                calories: 93,
                protein: 3.0,
                carbs: 19.0,
                fat: 1.1,
                fiber: 3.6,
                sodium: 2.0,
                fdcId: 0
            ),
            FoodItem(
                name: "Dark Chocolate (1 oz)",
                brandOwner: nil,
                calories: 170,
                protein: 2.0,
                carbs: 13.0,
                fat: 12.0,
                fiber: 3.0,
                sodium: 5.0,
                fdcId: 0
            )
        ]
    }
    
    // MARK: - USDA API Search
    private func searchUSDADatabase(query: String) async -> [FoodItem] {
        let urlString = "\(baseURL)/foods/search?api_key=\(apiKey)&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&pageSize=25"
        
        guard let url = URL(string: urlString) else {
            return []
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check if response is successful
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let usdaResponse = try JSONDecoder().decode(USDASearchResponse.self, from: data)
                return usdaResponse.foods.map { $0.toFoodItem() }
            } else {
                return []
            }
        } catch {
            return []
        }
    }
    
    // MARK: - Personalized Nutrition Targets
    func getPersonalizedTargets(for profile: UserProfile) -> PersonalizedTargets {
        let targets = CalorieCalculator.calculateDailyTargets(for: profile)
        
        // Enhanced macronutrient calculations based on goals
        let proteinTarget = calculateProteinTarget(for: profile)
        let carbTarget = calculateCarbTarget(for: profile, totalCalories: targets.calories, protein: proteinTarget)
        let fatTarget = calculateFatTarget(for: profile, totalCalories: targets.calories, protein: proteinTarget, carbs: carbTarget)
        
        // Micronutrient targets based on age, gender, and activity level
        let micronutrients = calculateMicronutrientTargets(for: profile)
        
        return PersonalizedTargets(
            calories: targets.calories,
            protein: proteinTarget,
            carbs: carbTarget,
            fat: fatTarget,
            fiber: calculateFiberTarget(for: profile),
            sodium: calculateSodiumTarget(for: profile),
            micronutrients: micronutrients
        )
    }
    
    // MARK: - Enhanced Macronutrient Calculations
    private func calculateProteinTarget(for profile: UserProfile) -> Double {
        let baseProtein = profile.weight * 2.0 // 2g per kg body weight
        
        // Adjust based on goals
        switch profile.fastingGoal {
        case .muscleGain:
            return baseProtein * 1.2 // 20% more for muscle building
        case .weightLoss:
            return baseProtein * 1.1 // 10% more to preserve muscle
        case .maintenance:
            return baseProtein
        case .generalHealth:
            return baseProtein * 1.05 // 5% more for general health
        }
    }
    
    private func calculateCarbTarget(for profile: UserProfile, totalCalories: Int, protein: Double) -> Double {
        let proteinCalories = protein * 4
        let remainingCalories = Double(totalCalories) - proteinCalories
        
        // Adjust carbs based on goals
        switch profile.fastingGoal {
        case .weightLoss:
            return (remainingCalories * 0.35) / 4 // 35% of remaining calories
        case .muscleGain:
            return (remainingCalories * 0.45) / 4 // 45% of remaining calories
        case .maintenance:
            return (remainingCalories * 0.4) / 4 // 40% of remaining calories
        case .generalHealth:
            return (remainingCalories * 0.4) / 4 // 40% of remaining calories
        }
    }
    
    private func calculateFatTarget(for profile: UserProfile, totalCalories: Int, protein: Double, carbs: Double) -> Double {
        let proteinCalories = protein * 4
        let carbCalories = carbs * 4
        let fatCalories = Double(totalCalories) - proteinCalories - carbCalories
        
        return fatCalories / 9
    }
    
    private func calculateFiberTarget(for profile: UserProfile) -> Double {
        // 14g per 1000 calories
        let baseFiber = (Double(profile.dailyCalorieTarget) / 1000) * 14
        
        // Adjust based on age
        if profile.age > 50 {
            return baseFiber * 0.9 // Slightly less for older adults
        }
        return baseFiber
    }
    
    private func calculateSodiumTarget(for profile: UserProfile) -> Double {
        // Base sodium target: 2300mg for adults
        var baseSodium = 2300.0
        
        // Adjust based on age
        if profile.age > 50 {
            baseSodium = 1500.0 // Lower for older adults
        }
        
        // Adjust based on activity level
        switch profile.activityLevel {
        case .veryActive, .extremelyActive:
            baseSodium += 500 // More sodium for high activity
        default:
            break
        }
        
        return baseSodium
    }
    
    private func calculateMicronutrientTargets(for profile: UserProfile) -> MicronutrientTargets {
        let age = profile.age
        let gender = profile.gender
        
        return MicronutrientTargets(
            vitaminD: calculateVitaminDTarget(age: age, gender: gender),
            calcium: calculateCalciumTarget(age: age, gender: gender),
            iron: calculateIronTarget(age: age, gender: gender),
            vitaminB12: calculateVitaminB12Target(age: age, gender: gender),
            folate: calculateFolateTarget(age: age, gender: gender),
            vitaminC: calculateVitaminCTarget(age: age, gender: gender),
            potassium: calculatePotassiumTarget(age: age, gender: gender),
            magnesium: calculateMagnesiumTarget(age: age, gender: gender)
        )
    }
    
    // MARK: - Micronutrient Calculations
    private func calculateVitaminDTarget(age: Int, gender: Gender) -> Double {
        if age < 70 {
            return 600 // IU
        } else {
            return 800 // IU
        }
    }
    
    private func calculateCalciumTarget(age: Int, gender: Gender) -> Double {
        if age < 50 {
            return 1000 // mg
        } else {
            return 1200 // mg
        }
    }
    
    private func calculateIronTarget(age: Int, gender: Gender) -> Double {
        if gender == .male {
            return age < 19 ? 11 : 8 // mg
        } else {
            return age < 50 ? 18 : 8 // mg (higher for premenopausal women)
        }
    }
    
    private func calculateVitaminB12Target(age: Int, gender: Gender) -> Double {
        return 2.4 // mcg for all adults
    }
    
    private func calculateFolateTarget(age: Int, gender: Gender) -> Double {
        return 400 // mcg for all adults
    }
    
    private func calculateVitaminCTarget(age: Int, gender: Gender) -> Double {
        return gender == .male ? 90 : 75 // mg
    }
    
    private func calculatePotassiumTarget(age: Int, gender: Gender) -> Double {
        return gender == .male ? 3400 : 2600 // mg
    }
    
    private func calculateMagnesiumTarget(age: Int, gender: Gender) -> Double {
        return gender == .male ? 400 : 310 // mg
    }
}

// MARK: - Data Models
struct PersonalizedTargets {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sodium: Double
    let micronutrients: MicronutrientTargets
}

struct MicronutrientTargets {
    let vitaminD: Double // IU
    let calcium: Double // mg
    let iron: Double // mg
    let vitaminB12: Double // mcg
    let folate: Double // mcg
    let vitaminC: Double // mg
    let potassium: Double // mg
    let magnesium: Double // mg
}

struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let brandOwner: String?
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double?
    let sodium: Double?
    let fdcId: Int
}

// MARK: - USDA API Response Models
struct USDASearchResponse: Codable {
    let foods: [USDAFood]
}

struct USDAFood: Codable {
    let fdcId: Int
    let description: String
    let brandOwner: String?
    let foodNutrients: [FoodNutrient]
    
    func toFoodItem() -> FoodItem {
        let nutrients = Dictionary(uniqueKeysWithValues: foodNutrients.map { ($0.nutrientId, $0.value) })
        
        // Enhanced nutrient extraction with better fallbacks
        let calories = Int(nutrients[1008] ?? nutrients[1062] ?? 0) // Energy (kcal) - try both common IDs
        let protein = nutrients[1003] ?? 0 // Protein (g)
        let carbs = nutrients[205] ?? 0 // Carbohydrate (g)
        let fat = nutrients[204] ?? 0 // Total lipid (fat) (g)
        let fiber = nutrients[1079] ?? nutrients[1078] ?? 0 // Fiber (g) - try both common IDs
        let sodium = nutrients[1093] ?? 0 // Sodium (mg)
        
        // Validate and correct nutrition data
        let validatedCalories = max(0, calories)
        let validatedProtein = max(0, protein)
        let validatedCarbs = max(0, carbs)
        let validatedFat = max(0, fat)
        let validatedFiber = max(0, fiber)
        let validatedSodium = max(0, sodium)
        
        return FoodItem(
            name: description,
            brandOwner: brandOwner,
            calories: validatedCalories,
            protein: validatedProtein,
            carbs: validatedCarbs,
            fat: validatedFat,
            fiber: validatedFiber > 0 ? validatedFiber : nil,
            sodium: validatedSodium > 0 ? validatedSodium : nil,
            fdcId: fdcId
        )
    }
}

struct FoodNutrient: Codable {
    let nutrientId: Int
    let value: Double
} 