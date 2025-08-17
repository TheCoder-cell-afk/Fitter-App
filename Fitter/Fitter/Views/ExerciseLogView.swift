import SwiftUI

struct ExerciseLogView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    @State private var healthKitService: HealthKitService?
    
    @State private var exerciseName = ""
    @State private var duration: Double = 30.0
    @State private var caloriesBurned: Double = 150.0
    @State private var steps: Double = 0.0
    @State private var selectedType: ExerciseType = .cardio
    @State private var notes = ""
    @State private var animateContent = false
    
    // Animation states
    @State private var saveButtonScale: CGFloat = 1.0
    @State private var cancelButtonScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Log Exercise")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Track your workout session")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    
                    // Exercise Name
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Exercise Name")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("e.g., Running, Weight Training", text: $exerciseName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 25)
                    
                    // Exercise Type
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Exercise Type")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(ExerciseType.allCases, id: \.self) { type in
                                Button(action: {
                                    selectedType = type
                                }) {
                                    HStack {
                                        Image(systemName: type.icon)
                                            .font(.title3)
                                            .foregroundColor(selectedType == type ? .white : Color(type.color))
                                        
                                        Text(type.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selectedType == type ? .white : .primary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedType == type ? Color(type.color) : Color(.systemGray6))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)
                    
                    // Duration and Calories
                    HStack(spacing: 16) {
                        // Duration
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Duration (min)")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                Text("\(Int(duration))")
                                    .font(.system(size: 32, weight: .heavy))
                                    .foregroundColor(.blue)
                                
                                Slider(value: $duration, in: 5...180, step: 5)
                                    .accentColor(.blue)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        
                        // Calories
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Calories Burned")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                Text("\(Int(caloriesBurned))")
                                    .font(.system(size: 32, weight: .heavy))
                                    .foregroundColor(.orange)
                                
                                Slider(value: $caloriesBurned, in: 10...1000, step: 10)
                                    .accentColor(.orange)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 35)
                    
                    // Steps (Optional)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Steps (Optional)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            Text("\(Int(steps))")
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(.green)
                            
                            Slider(value: $steps, in: 0...5000, step: 100)
                                .accentColor(.green)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 37)
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes (Optional)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("Add any notes about your workout...", text: $notes, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16, weight: .medium))
                            .lineLimit(3...6)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 42)
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                cancelButtonScale = 0.95
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    cancelButtonScale = 1.0
                                }
                            }
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                )
                        }
                        .scaleEffect(cancelButtonScale)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                saveButtonScale = 0.95
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    saveButtonScale = 1.0
                                }
                            }
                            
                            saveExercise()
                        }) {
                            Text("Save Exercise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(exerciseName.isEmpty ? Color(.systemGray4) : .blue)
                                )
                        }
                        .disabled(exerciseName.isEmpty)
                        .scaleEffect(saveButtonScale)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 47)
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGray6))
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                // Initialize HealthKit service safely
                if healthKitService == nil {
                    healthKitService = HealthKitService.shared
                }
                
                withAnimation(.easeOut(duration: 0.6)) {
                    animateContent = true
                }
            }
        }
    }
    
    private func saveExercise() {
        let exercise = Exercise(
            name: exerciseName,
            duration: duration * 60, // Convert to seconds
            caloriesBurned: Int(caloriesBurned),
            type: selectedType,
            notes: notes.isEmpty ? nil : notes
        )
        
        dataManager.addExercise(exercise)
        
        // Log to HealthKit if authorized
        if let service = healthKitService, service.isAuthorized {
            let stepsToLog = steps > 0 ? Int(steps) : nil
            service.logExercise(
                name: exerciseName,
                duration: duration * 60,
                calories: caloriesBurned,
                steps: stepsToLog
            )
        }
        
        dismiss()
    }
}

#Preview {
    ExerciseLogView()
} 