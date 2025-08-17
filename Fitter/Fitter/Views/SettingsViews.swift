import SwiftUI

struct NotificationsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var animateContent = false
    
    // Animation states for buttons
    @State private var toggleButtonScale: CGFloat = 1.0
    @State private var saveButtonScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notification Preferences") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Push Notifications")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Receive reminders and updates")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Enhanced button feedback
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    toggleButtonScale = 0.9
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        toggleButtonScale = 1.0
                                    }
                                }
                                
                                notificationManager.requestNotificationPermission()
                            }) {
                                Image(systemName: notificationManager.isNotificationsEnabled ? "bell.fill" : "bell.slash.fill")
                                    .font(.title2)
                                    .foregroundColor(notificationManager.isNotificationsEnabled ? .green : .orange)
                            }
                            .scaleEffect(toggleButtonScale)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fasting Reminders")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Get notified when it's time to start or end your fast")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calorie Logging Reminders")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Reminders to log your meals and track nutrition")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 40)
                    }
                }
                
                Section {
                    Button("🧪 Test Notification") {
                        notificationManager.sendTestNotification()
                    }
                    .foregroundColor(.blue)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 45)
                    
                    Button("Save Changes") {
                        // Enhanced button feedback
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            saveButtonScale = 0.95
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                saveButtonScale = 1.0
                            }
                        }
                        
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .scaleEffect(saveButtonScale)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 50)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    animateContent = true
                }
            }
        }
    }
}



struct DataSyncSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateContent = false
    @State private var isICloudSyncEnabled = true
    @State private var isAutoBackupEnabled = true
    @State private var syncFrequency = "Daily"
    
    // Animation states for buttons
    @State private var iCloudButtonScale: CGFloat = 1.0
    @State private var backupButtonScale: CGFloat = 1.0
    @State private var saveButtonScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Data Sync Options") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("iCloud Sync")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Sync data across devices")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Enhanced button feedback
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    iCloudButtonScale = 0.9
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        iCloudButtonScale = 1.0
                                    }
                                }
                                
                                isICloudSyncEnabled.toggle()
                            }) {
                                Image(systemName: isICloudSyncEnabled ? "icloud.fill" : "icloud.slash.fill")
                                    .font(.title2)
                                    .foregroundColor(isICloudSyncEnabled ? .blue : .gray)
                            }
                            .scaleEffect(iCloudButtonScale)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Auto Backup")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text("Automatically backup your data")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                // Enhanced button feedback
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    backupButtonScale = 0.9
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        backupButtonScale = 1.0
                                    }
                                }
                                
                                isAutoBackupEnabled.toggle()
                            }) {
                                Image(systemName: isAutoBackupEnabled ? "arrow.clockwise.circle.fill" : "arrow.clockwise.circle.slash.fill")
                                    .font(.title2)
                                    .foregroundColor(isAutoBackupEnabled ? .green : .gray)
                            }
                            .scaleEffect(backupButtonScale)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 30)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sync Frequency")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("How often to sync your data")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Picker("Sync Frequency", selection: $syncFrequency) {
                                Text("Hourly").tag("Hourly")
                                Text("Daily").tag("Daily")
                                Text("Weekly").tag("Weekly")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 40)
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        // Enhanced button feedback
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            saveButtonScale = 0.95
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                saveButtonScale = 1.0
                            }
                        }
                        
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .scaleEffect(saveButtonScale)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 50)
                }
            }
            .navigationTitle("Data Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    animateContent = true
                }
            }
        }
    }
}

#Preview {
    NotificationsSettingsView()
} 