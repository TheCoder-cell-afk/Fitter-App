import SwiftUI

struct WaterTrackerView: View {
    @ObservedObject private var waterTracker = WaterTrackerService.shared
    @State private var addAmount: Double = 250

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Progress Circle
                VStack(spacing: 8) {
                    Text("Today's Intake")
                        .font(.headline)
                    ZStack {
                        Circle()
                            .stroke(Color.cyan.opacity(0.2), lineWidth: 20)
                            .frame(width: 140, height: 140)
                        Circle()
                            .trim(from: 0, to: CGFloat(waterTracker.getTodayProgress()))
                            .stroke(Color.cyan, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 140, height: 140)
                        VStack {
                            Text("\(Int(waterTracker.getTodayWaterIntake())) ml")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("/ \(Int(waterTracker.dailyGoal)) ml")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Text(waterTracker.getProgressMessage())
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }

                // Add Water Entry
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Add")
                        .font(.subheadline)
                    HStack {
                        Stepper("\(Int(addAmount)) ml", value: $addAmount, in: 50...2000, step: 50)
                            .labelsHidden()
                        Button(action: {
                            waterTracker.addWaterEntry(amount: addAmount)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.cyan)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // List of Today's Entries
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Entries")
                        .font(.subheadline)
                    if waterTracker.getTodayEntries().isEmpty {
                        Text("No entries yet. Add water to get started!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        List {
                            ForEach(waterTracker.getTodayEntries()) { entry in
                                HStack {
                                    Text(entry.formattedTime)
                                        .font(.caption)
                                    Spacer()
                                    Text(entry.formattedAmount)
                                }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let entry = waterTracker.getTodayEntries()[index]
                                    waterTracker.removeWaterEntry(entry)
                                }
                            }
                        }
                        .frame(height: 180)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Water Tracker")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// Optional preview
#Preview {
    WaterTrackerView()
}
