import SwiftUI

struct StartFastingFromTimeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    
    @State private var startTime = Date()
    @State private var fastingGoal: FastingGoal = .generalHealth
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Fasting Goal", selection: $fastingGoal) {
                        ForEach(FastingGoal.allCases, id: \.self) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                } header: {
                    Text("Fasting Details")
                }
                
                Section("Duration") {
                    HStack {
                        Text("Time Since Start")
                        Spacer()
                        Text(timeSinceStartString)
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                }
                
                Section("Info") {
                    Text("This will start an active fasting session that began at the time you selected. The timer will continue counting from that time.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button("Start Fasting Session") {
                        startFastingSession()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(!isValidStartTime)
                }
            }
            .navigationTitle("Start Fasting From Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Fasting Session", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("started") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var timeSinceStartString: String {
        let timeSince = Date().timeIntervalSince(startTime)
        let hours = Int(timeSince) / 3600
        let minutes = Int(timeSince) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
    
    private var isValidStartTime: Bool {
        let timeSince = Date().timeIntervalSince(startTime)
        return timeSince >= 0 && timeSince < 24 * 3600 // Must be in the past and not more than 24 hours ago
    }
    
    private func startFastingSession() {
        guard isValidStartTime else {
            alertMessage = "Please select a valid start time (must be in the past and not more than 24 hours ago)"
            showingAlert = true
            return
        }
        
        // Get target duration based on user profile or use default
        let targetDuration: TimeInterval
        if let profile = dataManager.userProfile {
            let plan = FastingPlan.planForActivityLevel(profile.activityLevel)
            targetDuration = plan.fastingWindow
        } else {
            // Default to 16:8 fasting plan
            targetDuration = 16 * 3600 // 16 hours
        }
        
        // Start fasting session from the selected time
        dataManager.startFastingSessionFromTime(targetDuration: targetDuration, startTime: startTime)
        
        // Award XP for starting fasting
        NotificationCenter.default.post(
            name: .init("AwardXP"),
            object: [
                "amount": 15,
                "reason": "Started fasting session"
            ]
        )
        
        alertMessage = "Fasting session started successfully from \(timeSinceStartString)! +15 XP"
        showingAlert = true
    }
}

#Preview {
    StartFastingFromTimeView()
} 