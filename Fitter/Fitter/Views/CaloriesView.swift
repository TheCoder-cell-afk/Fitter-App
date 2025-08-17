import SwiftUI

struct CaloriesView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingAddFood = false
    @State private var animateProgress = false
    
    // Animation states for all buttons
    @State private var addFoodButtonScale: CGFloat = 1.0
    @State private var headerAddButtonScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Calories Summary Card
                    caloriesSummaryCard
                    
                    // Macronutrients Section
                    macronutrientsSection
                    
                    // Today's Meals Section
                    todaysMealsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGray6))
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Enhanced button feedback
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            addFoodButtonScale = 0.9
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                addFoodButtonScale = 1.0
                            }
                        }
                        
                        showingAddFood = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .scaleEffect(addFoodButtonScale)
                }
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .init("ShowAddFoodSheet"))) { _ in
                showingAddFood = true
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    animateProgress = true
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(formatDate(Date()))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // Enhanced button feedback
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    headerAddButtonScale = 0.9
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        headerAddButtonScale = 1.0
                    }
                }
                
                showingAddFood = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .scaleEffect(headerAddButtonScale)
        }
        .padding(.top, 20)
    }
    
    private var caloriesSummaryCard: some View {
        let nutrition = dataManager.getTodayNutrition()
        let progress = min(nutrition.caloriesProgress, 1.0)
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Calories")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Daily Goal: \(nutrition.targetCalories)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                HStack(alignment: .bottom, spacing: 8) {
                    Text("\(nutrition.totalCalories)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("calories consumed")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Progress bar
                VStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray4))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * progress, height: 8)
                                .animation(.easeInOut(duration: 1), value: progress)
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("0")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(nutrition.remainingCalories) calories remaining")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var macronutrientsSection: some View {
        let nutrition = dataManager.getTodayNutrition()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Macronutrients")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                MacroCard(
                    title: "Protein",
                    value: nutrition.totalProtein,
                    goal: 120,
                    color: .blue,
                    animateProgress: animateProgress
                )
                
                MacroCard(
                    title: "Carbs",
                    value: nutrition.totalCarbs,
                    goal: 250,
                    color: .green,
                    animateProgress: animateProgress
                )
                
                MacroCard(
                    title: "Fat",
                    value: nutrition.totalFat,
                    goal: 60,
                    color: .orange,
                    animateProgress: animateProgress
                )
            }
        }
    }
    
    private var todaysMealsSection: some View {
        let todaysEntries = dataManager.getTodayFoodEntries()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Today's Meals")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            if todaysEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No meals logged today")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Start logging your meals to track your nutrition")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(todaysEntries.enumerated()), id: \.element.id) { index, entry in
                        MealEntryRow(entry: entry, index: index) {
                            dataManager.removeFoodEntry(entry)
                        }
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}

struct MacroCard: View {
    let title: String
    let value: Double
    let goal: Double
    let color: Color
    let animateProgress: Bool
    
    private var progress: Double {
        min(value / goal, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray4))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(.easeInOut(duration: 1), value: progress)
                }
            }
            .frame(height: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("\(Int(value))g")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("\(Int(goal))g goal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .frame(maxWidth: .infinity)
    }
}

struct MealEntryRow: View {
    let entry: FoodEntry
    let index: Int
    let onDelete: () -> Void
    
    private var mealIcon: String {
        let hour = Calendar.current.component(.hour, from: entry.date)
        switch hour {
        case 5..<11: return "sun.max.fill"
        case 11..<16: return "sun.max.fill"
        case 16..<21: return "moon.fill"
        default: return "moon.stars.fill"
        }
    }
    
    private var mealName: String {
        let hour = Calendar.current.component(.hour, from: entry.date)
        switch hour {
        case 5..<11: return "Breakfast"
        case 11..<16: return "Lunch"
        case 16..<21: return "Dinner"
        default: return "Snack"
        }
    }
    
    private var iconColor: Color {
        let hour = Calendar.current.component(.hour, from: entry.date)
        switch hour {
        case 5..<11: return .blue
        case 11..<16: return .yellow
        case 16..<21: return .orange
        default: return .purple
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Meal icon
            Image(systemName: mealIcon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mealName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(entry.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.calories)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("calories")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var nutritionAPI = NutritionAPIService.shared
    @State private var foodName = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var animateContent = false
    @State private var searchText = ""
    @State private var showingSearchResults = false
    
    // Animation states for all buttons
    @State private var searchButtonScale: CGFloat = 1.0
    @State private var addFoodButtonScale: CGFloat = 1.0
    @State private var cancelButtonScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Search Food Database") {
                    HStack {
                        TextField("Search for food...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            // Enhanced button feedback
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                searchButtonScale = 0.9
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    searchButtonScale = 1.0
                                }
                            }
                            
                            Task {
                                await nutritionAPI.searchFood(query: searchText)
                                showingSearchResults = true
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.blue)
                        }
                        .disabled(searchText.isEmpty)
                        .scaleEffect(searchButtonScale)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    
                    if nutritionAPI.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Searching...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                    }
                    
                    if let errorMessage = nutritionAPI.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 40)
                    }
                }
                
                if !nutritionAPI.searchResults.isEmpty && showingSearchResults {
                    Section("Search Results") {
                        ForEach(nutritionAPI.searchResults) { food in
                            Button(action: {
                                selectFood(food)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(food.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    if let brand = food.brandOwner {
                                        Text(brand)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("\(food.calories) cal • \(String(format: "%.1f", food.protein))g protein • \(String(format: "%.1f", food.carbs))g carbs • \(String(format: "%.1f", food.fat))g fat")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Section("Manual Entry") {
                    TextField("Food name", text: $foodName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 50)
                    
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 60)
                }
                
                Section("Macronutrients (optional)") {
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 70)
                    
                    TextField("Carbs (g)", text: $carbs)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 80)
                    
                    TextField("Fat (g)", text: $fat)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 90)
                }
                
                Section {
                    Button("Add Food") {
                        // Enhanced button feedback
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            addFoodButtonScale = 0.95
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                addFoodButtonScale = 1.0
                            }
                        }
                        
                        addFood()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .disabled(foodName.isEmpty || calories.isEmpty)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 100)
                    .scaleEffect(addFoodButtonScale)
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Enhanced button feedback
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            cancelButtonScale = 0.95
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                cancelButtonScale = 1.0
                            }
                        }
                        
                        dismiss()
                    }
                    .scaleEffect(cancelButtonScale)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    animateContent = true
                }
            }
        }
    }
    
    private func selectFood(_ food: FoodItem) {
        foodName = food.name
        calories = String(food.calories)
        protein = String(format: "%.1f", food.protein)
        carbs = String(format: "%.1f", food.carbs)
        fat = String(format: "%.1f", food.fat)
        
        // Hide search results after selection
        showingSearchResults = false
        searchText = ""
    }
    
    private func addFood() {
        guard let caloriesInt = Int(calories) else { return }
        
        let proteinDouble = Double(protein) ?? 0
        let carbsDouble = Double(carbs) ?? 0
        let fatDouble = Double(fat) ?? 0
        
        let entry = FoodEntry(
            name: foodName,
            calories: caloriesInt,
            protein: proteinDouble,
            carbs: carbsDouble,
            fat: fatDouble
        )
        
        dataManager.addFoodEntry(entry)
        dismiss()
    }
}

#Preview {
    CaloriesView()
} 