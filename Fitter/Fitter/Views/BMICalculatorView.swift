import SwiftUI

struct BMICalculatorView: View {
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var result: BMICalculatorService.BMIResult?
    @State private var showResult = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        Text("BMI Calculator")
                            .font(.title.bold())
                        Text("Calculate your Body Mass Index and get health recommendations.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Input Form
                    VStack(spacing: 20) {
                        HStack {
                            Text("Weight")
                                .frame(width: 80, alignment: .leading)
                            TextField("70", text: $weight)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            Text("kg")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Height")
                                .frame(width: 80, alignment: .leading)
                            TextField("170", text: $height)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            Text("cm")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    
                    // Calculate Button
                    Button(action: calculateBMI) {
                        HStack {
                            Image(systemName: "equal")
                            Text("Calculate BMI")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                    }
                    .disabled(weight.isEmpty || height.isEmpty)
                    .opacity(weight.isEmpty || height.isEmpty ? 0.6 : 1.0)
                    
                    // Results
                    if let result = result, showResult {
                        VStack(spacing: 20) {
                            VStack(spacing: 8) {
                                Text("Your BMI")
                                    .font(.headline)
                                Text(String(format: "%.1f", result.bmi))
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(colorForBMICategory(result.category))
                                Text(result.category.rawValue)
                                    .font(.title3.bold())
                                    .foregroundColor(colorForBMICategory(result.category))
                                Text(result.category.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Healthy Range: \(result.category.range)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(colorForBMICategory(result.category).opacity(0.12))
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recommendations")
                                    .font(.headline)
                                ForEach(result.recommendations.prefix(3), id: \.self) { recommendation in
                                    Text("• \(recommendation)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        .padding(.top, 12)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGray6))
            .navigationTitle("BMI Calculator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Helper to get a color for the BMI category
    private func colorForBMICategory(_ category: BMICalculatorService.BMICategory) -> Color {
        switch category {
        case .underweight:
            return .blue
        case .normal:
            return .green
        case .overweight:
            return .yellow
        case .obeseClass1:
            return .orange
        case .obeseClass2:
            return .red
        case .obeseClass3:
            return .purple
        }
    }
    
    // Calculate BMI
    private func calculateBMI() {
        guard let weightValue = Double(weight), let heightValue = Double(height) else {
            showResult = false
            return
        }
        result = BMICalculatorService.shared.calculateBMI(weight: weightValue, height: heightValue)
        showResult = true
    }
}

#Preview {
    BMICalculatorView()
}
