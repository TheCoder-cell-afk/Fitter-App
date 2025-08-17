import SwiftUI

struct ExerciseCard: View {
    let exercise: Exercise
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    @State private var cardScale: CGFloat = 1.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with type icon and name
            HStack {
                Image(systemName: exercise.type.icon)
                    .font(.title2)
                    .foregroundColor(Color(exercise.type.color))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color(exercise.type.color).opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(exercise.type.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        cardScale = 0.95
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            cardScale = 1.0
                        }
                    }
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                }
            }
            
            // Stats row
            HStack(spacing: 24) {
                // Duration
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(exercise.duration / 60)) min")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                // Calories
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calories")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(exercise.caloriesBurned)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                // Time
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(exercise.date))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            
            // Notes (if any)
            if let notes = exercise.notes, !notes.isEmpty {
                Text(notes)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(cardScale)
        .alert("Delete Exercise", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this exercise?")
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ExerciseCard(
        exercise: Exercise(
            name: "Morning Run",
            duration: 30 * 60,
            caloriesBurned: 250,
            type: .cardio,
            notes: "Great morning run in the park!"
        )
    ) {
        print("Delete exercise")
    }
    .padding()
} 