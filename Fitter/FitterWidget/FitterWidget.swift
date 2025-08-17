//
//  FitterWidget.swift
//  FitterWidget
//
//  Created by Jabir Ould Mohamed on 7/15/25.
//

import WidgetKit
import SwiftUI

struct FitterWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.jabir.Fitter.FitterWidget",
            provider: FitterWidgetProvider()
        ) { entry in
            FitterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Fasting Progress")
        .description("Track your fasting progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct FitterWidgetEntry: TimelineEntry, Equatable {
    let date: Date
    let fastingState: String
    let progress: Double // 0.0 to 1.0
    let timeRemaining: String
    let motivationalText: String
}

struct FitterWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FitterWidgetEntry {
        FitterWidgetEntry(date: Date(), fastingState: "Fasting", progress: 0.5, timeRemaining: "8h 30m left", motivationalText: "Keep going!")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FitterWidgetEntry) -> Void) {
        let entry = FitterWidgetEntry(date: Date(), fastingState: "Fasting", progress: 0.5, timeRemaining: "8h 30m left", motivationalText: "You're halfway there!")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FitterWidgetEntry>) -> Void) {
        // In a real app, fetch fasting data from shared storage
        let entry = FitterWidgetEntry(date: Date(), fastingState: "Fasting", progress: 0.7, timeRemaining: "4h 12m left", motivationalText: "Stay strong!")
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct FitterWidgetEntryView: View {
    let entry: FitterWidgetEntry
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Fasting")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(entry.fastingState)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
                ProgressView(value: entry.progress)
                    .accentColor(.blue)
                    .progressViewStyle(LinearProgressViewStyle())
                HStack {
                    Text(String(format: "%d%%", Int(entry.progress * 100)))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(entry.timeRemaining)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                Text(entry.motivationalText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

#Preview {
    FitterWidgetEntryView(entry: FitterWidgetEntry(date: Date(), fastingState: "Fasting", progress: 0.7, timeRemaining: "4h 12m left", motivationalText: "Stay strong!"))
}

#Preview {
    FitterWidgetEntryView(entry: FitterWidgetEntry(date: Date(), fastingState: "Fasting", progress: 0.3, timeRemaining: "12h 10m left", motivationalText: "You can do it!"))
} 