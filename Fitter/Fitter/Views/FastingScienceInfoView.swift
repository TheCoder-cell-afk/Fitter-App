import SwiftUI

struct FastingScienceInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var fastingScience = FastingScienceService.shared
    @State private var selectedPhase: FastingScienceService.FastingPhase?
    @State private var animateContent = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "flame.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Fasting Science")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Understanding ketosis and fat burning")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    
                    // Fasting Phases Timeline
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Fasting Phases Timeline")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        ForEach(Array(fastingScience.getFastingPhases().enumerated()), id: \.offset) { index, phase in
                            FastingPhaseCard(phase: phase, isSelected: selectedPhase?.name == phase.name) {
                                selectedPhase = selectedPhase?.name == phase.name ? nil : phase
                            }
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 30 + Double(index * 10))
                        }
                    }
                    
                    // Scientific Summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Scientific Evidence")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ScienceInfoRow(
                                icon: "flame.fill",
                                title: "Fat Burning Timeline",
                                description: "Peak fat burning occurs at 16-24 hours of fasting",
                                color: .orange
                            )
                            
                            ScienceInfoRow(
                                icon: "brain.head.profile",
                                title: "Mental Clarity",
                                description: "Ketones provide clean energy for the brain",
                                color: .blue
                            )
                            
                            ScienceInfoRow(
                                icon: "heart.fill",
                                title: "Metabolic Health",
                                description: "Improved insulin sensitivity after 12-16 hours",
                                color: .green
                            )
                            
                            ScienceInfoRow(
                                icon: "gear.circle.fill",
                                title: "Cellular Repair",
                                description: "Autophagy begins at 24+ hours of fasting",
                                color: .purple
                            )
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 40)
                    }
                    
                    // Tips Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Fasting Tips")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            ForEach(fastingScience.getFastingTips(), id: \.self) { tip in
                                HStack(spacing: 12) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.yellow)
                                    
                                    Text(tip)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 50)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGray6))
            .navigationTitle("")
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateContent = true
                }
            }
        }
    }
}

struct FastingPhaseCard: View {
    let phase: FastingScienceService.FastingPhase
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(phase.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("\(phase.startHour)-\(phase.endHour) hours")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(phase.ketoneLevel)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("Ketones")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                if isSelected {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(phase.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Primary Fuel: \(phase.primaryFuel)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                            
                            Text("Fat Burning: \(phase.fatBurning)")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.green)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Benefits:")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            ForEach(phase.benefits, id: \.self) { benefit in
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.green)
                                    Text(benefit)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.3), value: isSelected)
    }
}

struct ScienceInfoRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    FastingScienceInfoView()
} 