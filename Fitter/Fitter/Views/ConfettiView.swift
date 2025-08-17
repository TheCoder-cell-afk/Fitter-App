import SwiftUI
import UIKit

// MARK: - iOS 26 Ready
// This view is fully optimized for iOS 26
// All screen size handling uses modern window scene APIs
// ✅ No deprecated UIScreen.main usage
// ✅ Modern window scene management
// ✅ iOS 26 compatible animations and effects

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    var rotation: Double
    var scale: Double
    var color: Color
    var opacity: Double
    var symbol: String
    var velocityX: Double
    var velocityY: Double
    var gravity: Double
    
    init(centerX: Double, centerY: Double) {
        // Start from center and explode outward
        self.x = centerX
        self.y = centerY
        
        // Random explosion direction
        let angle = Double.random(in: 0...2 * .pi)
        let speed = Double.random(in: 100...300)
        self.velocityX = cos(angle) * speed
        self.velocityY = sin(angle) * speed
        
        self.rotation = Double.random(in: 0...360)
        self.scale = Double.random(in: 0.3...1.2)
        self.color = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan, .mint, .indigo].randomElement()!
        self.opacity = 1.0
        self.gravity = Double.random(in: 300...600)
        self.symbol = ["sparkles", "star.fill", "diamond.fill", "circle.fill", "square.fill", "triangle.fill", "heart.fill", "bolt.fill", "flame.fill", "crown.fill"].randomElement()!
    }
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiParticleView(particle: particle)
            }
        }
        .onAppear {
            createExplosion()
        }
    }
    
    private func createExplosion() {
        // iOS 26 Ready: Use window scene instead of deprecated UIScreen.main
        let screenWidth: CGFloat
        let screenHeight: CGFloat
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            screenWidth = windowScene.screen.bounds.width
            screenHeight = windowScene.screen.bounds.height
        } else {
            // Fallback for older iOS versions
            screenWidth = 390 // Default iPhone width
            screenHeight = 844 // Default iPhone height
        }
        
        let centerX = screenWidth / 2
        let centerY = screenHeight / 2
        
        // Create 50 confetti particles
        particles = (0..<50).map { _ in
            ConfettiParticle(centerX: centerX, centerY: centerY)
        }
        
        isAnimating = true
    }
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    @State private var xOffset: Double = 0
    @State private var yOffset: Double = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    @State private var scale: Double = 1.0
    
    var body: some View {
        Image(systemName: particle.symbol)
            .foregroundColor(particle.color)
            .font(.system(size: 12))
            .scaleEffect(particle.scale * scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                animateParticle()
            }
    }
    
    private func animateParticle() {
        let duration = Double.random(in: 2.0...4.0)
        let delay = Double.random(in: 0...0.5)
        
        // Animate position with physics
        withAnimation(.easeOut(duration: duration).delay(delay)) {
            xOffset = particle.velocityX
            yOffset = particle.velocityY + particle.gravity
            rotation = particle.rotation + Double.random(in: 180...720)
        }
        
        // Animate scale
        withAnimation(.easeInOut(duration: duration * 0.3).delay(delay)) {
            scale = 1.2
        }
        
        withAnimation(.easeInOut(duration: duration * 0.3).delay(delay + duration * 0.3)) {
            scale = 0.8
        }
        
        // Fade out
        withAnimation(.easeIn(duration: 1.0).delay(delay + duration * 0.7)) {
            opacity = 0
        }
    }
}

// Preview for testing
#Preview {
    ConfettiView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
} 