//
//  FitterWidgetLiveActivity.swift
//  FitterWidget
//
//  Created by Jabir Ould Mohamed on 7/15/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FitterWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FitterWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FitterWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FitterWidgetAttributes {
    fileprivate static var preview: FitterWidgetAttributes {
        FitterWidgetAttributes(name: "World")
    }
}

extension FitterWidgetAttributes.ContentState {
    fileprivate static var smiley: FitterWidgetAttributes.ContentState {
        FitterWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FitterWidgetAttributes.ContentState {
         FitterWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FitterWidgetAttributes.preview) {
   FitterWidgetLiveActivity()
} contentStates: {
    FitterWidgetAttributes.ContentState.smiley
    FitterWidgetAttributes.ContentState.starEyes
}
