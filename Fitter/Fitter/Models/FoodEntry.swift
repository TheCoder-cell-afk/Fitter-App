import Foundation

struct FoodEntry: Codable, Identifiable {
    var id = UUID()
    var name: String
    var calories: Int
    var protein: Double // grams
    var carbs: Double // grams
    var fat: Double // grams
    var date: Date
    
    init(name: String, calories: Int, protein: Double = 0, carbs: Double = 0, fat: Double = 0) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = Date()
    }
}

 