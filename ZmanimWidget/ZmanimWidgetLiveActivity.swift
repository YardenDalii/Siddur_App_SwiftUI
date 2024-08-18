//
//  ZmanimWidgetLiveActivity.swift
//  ZmanimWidget
//
//  Created by Yarden Dali on 04/04/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ZmanimWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ZmanimWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ZmanimWidgetAttributes.self) { context in
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

extension ZmanimWidgetAttributes {
    fileprivate static var preview: ZmanimWidgetAttributes {
        ZmanimWidgetAttributes(name: "World")
    }
}

extension ZmanimWidgetAttributes.ContentState {
    fileprivate static var smiley: ZmanimWidgetAttributes.ContentState {
        ZmanimWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ZmanimWidgetAttributes.ContentState {
         ZmanimWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ZmanimWidgetAttributes.preview) {
   ZmanimWidgetLiveActivity()
} contentStates: {
    ZmanimWidgetAttributes.ContentState.smiley
    ZmanimWidgetAttributes.ContentState.starEyes
}
