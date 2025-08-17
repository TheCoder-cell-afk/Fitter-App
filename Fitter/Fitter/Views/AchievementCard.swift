import SwiftUI

struct AchievementCard: View {
    let achievement: Achievement
    
    @State private var isFlipped = false
    @State private var isPressed = false
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Front of card
            VStack(spacing: 8) {
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(.yellow)
                Text(achievement.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            
            // Back of card (details)
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: achievement.iconName)
                        .font(.title)
                        .foregroundColor(.yellow)
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                if showConfetti {
                    ConfettiView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray5)))
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : -180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.6)) {
                isFlipped.toggle()
            }
            if !isFlipped {
                // Reset confetti when flipping back
                showConfetti = false
            } else {
                // Show confetti after flip
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation {
                        showConfetti = true
                    }
                }
            }
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = pressing
            }
        }, perform: {})
    }
} 
