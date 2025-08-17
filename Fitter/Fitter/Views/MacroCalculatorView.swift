import SwiftUI

struct MacroCalculatorView: View {
    @StateObject private var calculator = MacroCalculatorService.shared
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var feet: String = ""
    @State private var inches: String = ""
    @State private var age: String = ""
    @State private var selectedGender: MacroCalculatorService.Gender = .female
    @State private var selectedActivity: MacroCalculatorService.ActivityLevel = .moderatelyActive
    @State private var selectedGoal: MacroCalculatorService.Goal = .maintain
    @State private var bodyFatPercentage: String = ""
    @State private var useMetric = true
    @State private var includeBodyFat = false
    @State private var calculation: MacroCalculatorService.MacroCalculation?
    @State private var showingResults = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Input Form
                    inputFormSection
                    
                    // Calculate Button
                    calculateButton
                    
                    // Results Section
                    if let calculation = calculation, showingResults {
                        resultsSection(calculation: calculation)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGray6))
            .navigationTitle("Macro Calculator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Macro Calculator")
                .font(.title.bold())
            
            Text("Calculate your daily calorie and macronutrient needs based on the Mifflin-St Jeor equation")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Input Form
    private var inputFormSection: some View {
        VStack(spacing: 20) {
            // Units Toggle
            HStack {
                Text("Units:")
                    .font(.headline)
                
                Spacer()
                
                Picker("Units", selection: $useMetric) {
                    Text("Imperial").tag(false)
                    Text("Metric").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 150)
            }
            
            // Basic Info Card
            basicInfoCard
            
            // Activity & Goal Card
            activityGoalCard
            
            // Optional Body Fat Card
            bodyFatCard
        }
    }
    
    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Information")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Gender
                HStack {
                    Text("Gender:")
                        .frame(width: 80, alignment: .leading)
                    
                    Picker("Gender", selection: $selectedGender) {
                        Text("Female").tag(MacroCalculatorService.Gender.female)
                        Text("Male").tag(MacroCalculatorService.Gender.male)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Age
                HStack {
                    Text("Age:")
                        .frame(width: 80, alignment: .leading)
                    
                    TextField("25", text: $age)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                // Weight
                HStack {
                    Text("Weight:")
                        .frame(width: 80, alignment: .leading)
                    
                    TextField(useMetric ? "70" : "154", text: $weight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                    
                    Text(useMetric ? "kg" : "lbs")
                        .foregroundColor(.secondary)
                }
                
                // Height
                if useMetric {
                    HStack {
                        Text("Height:")
                            .frame(width: 80, alignment: .leading)
                        
                        TextField("170", text: $height)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        
                        Text("cm")
                            .foregroundColor(.secondary)
                    }
                } else {
                    HStack {
                        Text("Height:")
                            .frame(width: 80, alignment: .leading)
                        
                        HStack(spacing: 8) {
                            TextField("5", text: $feet)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                            Text("ft")
                                .foregroundColor(.secondary)
                            
                            TextField("7", text: $inches)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                            Text("in")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var activityGoalCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity & Goal")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Activity Level
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity Level:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Activity", selection: $selectedActivity) {
                        ForEach(MacroCalculatorService.ActivityLevel.allCases, id: \.self) { activity in
                            VStack(alignment: .leading) {
                                Text(activity.rawValue)
                                Text(activity.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(activity)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Goal
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goal:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(MacroCalculatorService.Goal.allCases, id: \.self) { goal in
                            VStack(alignment: .leading) {
                                Text(goal.rawValue)
                                Text(goal.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(goal)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private var bodyFatCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Body Fat % (Optional)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $includeBodyFat)
            }
            
            if includeBodyFat {
                VStack(alignment: .leading, spacing: 8) {
                    Text("For more accurate results if you're lean and know your body fat percentage")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("15", text: $bodyFatPercentage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        
                        Text("%")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Calculate Button
    private var calculateButton: some View {
        Button(action: calculateMacros) {
            HStack {
                Image(systemName: "chart.pie")
                    .font(.title2)
                Text("Calculate Macros")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1.0 : 0.6)
    }
    
    // MARK: - Results Section
    private func resultsSection(calculation: MacroCalculatorService.MacroCalculation) -> some View {
        VStack(spacing: 20) {
            // BMR & TDEE Card
            metabolismCard(calculation: calculation)
            
            // Daily Calories Card
            caloriesCard(calculation: calculation)
            
            // Macros Breakdown Card
            macrosCard(calculation: calculation)
            
            // Recommendations Card
            recommendationsCard(calculation: calculation)
        }
    }
    
    private func metabolismCard(calculation: MacroCalculatorService.MacroCalculation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Metabolism")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(Int(calculation.bmr))")
                        .font(.title.bold())
                        .foregroundColor(.blue)
                    Text("BMR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Basal Metabolic Rate")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(Int(calculation.tdee))")
                        .font(.title.bold())
                        .foregroundColor(.green)
                    Text("TDEE")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Total Daily Energy")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private func caloriesCard(calculation: MacroCalculatorService.MacroCalculation) -> some View {
        VStack(spacing: 16) {
            Text("Daily Calorie Target")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("\(calculation.targetCalories)")
                .font(.system(size: 48, weight: .heavy))
                .foregroundColor(.orange)
            
            Text("calories per day")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private func macrosCard(calculation: MacroCalculatorService.MacroCalculation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Macronutrient Breakdown")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                MacroRow(
                    name: "Protein",
                    grams: calculation.protein.grams,
                    calories: calculation.protein.calories,
                    percentage: calculation.protein.percentage,
                    color: .red
                )
                
                MacroRow(
                    name: "Carbs",
                    grams: calculation.carbs.grams,
                    calories: calculation.carbs.calories,
                    percentage: calculation.carbs.percentage,
                    color: .blue
                )
                
                MacroRow(
                    name: "Fat",
                    grams: calculation.fat.grams,
                    calories: calculation.fat.calories,
                    percentage: calculation.fat.percentage,
                    color: .green
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private func recommendationsCard(calculation: MacroCalculatorService.MacroCalculation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommendations")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(calculation.recommendations, id: \.self) { recommendation in
                    Text(recommendation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 2)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    // MARK: - Helper Functions
    private var isFormValid: Bool {
        !weight.isEmpty &&
        !age.isEmpty &&
        (useMetric ? !height.isEmpty : (!feet.isEmpty && !inches.isEmpty))
    }
    
    private func calculateMacros() {
        guard isFormValid,
              let weightValue = Double(weight),
              let ageValue = Int(age) else { return }
        
        let weightInKg: Double
        let heightInCm: Double
        
        if useMetric {
            weightInKg = weightValue
            heightInCm = Double(height) ?? 0
        } else {
            weightInKg = calculator.poundsToKg(weightValue)
            let feetValue = Int(feet) ?? 0
            let inchesValue = Int(inches) ?? 0
            heightInCm = calculator.feetInchesToCm(feet: feetValue, inches: inchesValue)
        }
        
        let bodyFat = includeBodyFat ? Double(bodyFatPercentage) : nil
        
        calculation = calculator.calculateMacros(
            weight: weightInKg,
            height: heightInCm,
            age: ageValue,
            gender: selectedGender,
            activityLevel: selectedActivity,
            goal: selectedGoal,
            bodyFatPercentage: bodyFat
        )
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showingResults = true
        }
    }
}

struct MacroRow: View {
    let name: String
    let grams: Double
    let calories: Double
    let percentage: Double
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                
                Text(name)
                    .font(.subheadline.bold())
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(grams))g")
                    .font(.subheadline.bold())
                Text("\(Int(calories)) cal • \(Int(percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    MacroCalculatorView()
}