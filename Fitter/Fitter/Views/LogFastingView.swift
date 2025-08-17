import SwiftUI

struct LogFastingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataManager = DataManager.shared
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var fastingGoal: FastingGoal = .generalHealth
    @State private var notes = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Start Time", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("End Time", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    
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
                        Text("Total Duration")
                        Spacer()
                        Text(durationString)
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                }
                
                Section("Notes (Optional)") {
                    TextField("Add notes about your fasting session...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button("Log Fasting Session") {
                        logFastingSession()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(!isValidSession)
                }
            }
            .navigationTitle("Log Past Fasting")
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
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var durationString: String {
        let duration = endDate.timeIntervalSince(startDate)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private var isValidSession: Bool {
        let duration = endDate.timeIntervalSince(startDate)
        return duration > 0 && duration < 24 * 3600 // Must be positive and less than 24 hours
    }
    
    private func logFastingSession() {
        guard isValidSession else {
            alertMessage = "Please select valid start and end times"
            showingAlert = true
            return
        }
        
        // Create a fasting session with calculated target duration
        let duration = endDate.timeIntervalSince(startDate)
        var session = FastingSession(targetDuration: duration)
        session.startTime = startDate
        session.endTime = endDate
        session.isActive = false
        
        // Add to data manager
        dataManager.addFastingSession(session)
        
        // Award XP for logging past fasting
        NotificationCenter.default.post(
            name: .init("AwardXP"),
            object: [
                "amount": 10,
                "reason": "Logged past fasting session"
            ]
        )
        
        alertMessage = "Fasting session logged successfully! +10 XP"
        showingAlert = true
    }
}

#Preview {
    LogFastingView()
} 