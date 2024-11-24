//
//  SiddurSettingsUtils.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 22/11/2024.
//

import Foundation
import SwiftUI


enum PrayerVersion: String, CaseIterable {
    case mizrah = "SiddurEdotHaMizrach"
    case sfarad = "SfaradPrayers"
    case ashkenaz = "AshkenazPrayers"

    var displayName: String {
        switch self {
        case .mizrah:
            return "MIZRAH_LOC"
        case .sfarad:
            return "SPAIN_LOC"
        case .ashkenaz:
            return "ASHKENAZ_LOC"
        }
    }

    /// File name for the prayer JSON
    var fileName: String {
        switch self {
        case .mizrah, .sfarad, .ashkenaz:
            return self.rawValue
        }
    }
}


struct DynamicStyledText: View {
    let input: String
    let customFontName: String
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        parseHTML(input, baseFontSize: appSettings.textSize)
    }

    private func parseHTML(_ html: String, baseFontSize: CGFloat) -> Text {
        var stack: [(String, CGFloat)] = [] // Stack to track tags and font sizes
        var result = Text("") // Final result
        var currentText = "" // Buffer for text between tags

        var i = html.startIndex
        while i < html.endIndex {
            if html[i] == "<" {
                // Flush current text buffer before processing the tag
                if !currentText.isEmpty {
                    result = result + applyStyles(currentText, stack: stack, baseFontSize: baseFontSize)
                    currentText = ""
                }

                // Parse the tag
                if let closingIndex = html[i...].firstIndex(of: ">") {
                    let tagContent = String(html[html.index(after: i)..<closingIndex])
                    i = html.index(after: closingIndex)

                    if tagContent.hasPrefix("/") {
                        // Closing tag
                        if !stack.isEmpty && stack.last!.0 == String(tagContent.dropFirst()) {
                            stack.removeLast() // Pop the stack
                        }
                    } else {
                        // Opening tag
                        let adjustedFontSize: CGFloat
                        switch tagContent {
                        case "big":
                            adjustedFontSize = (stack.last?.1 ?? baseFontSize) * 1.5
                        case "small":
                            adjustedFontSize = (stack.last?.1 ?? baseFontSize) * 0.75
                        default:
                            adjustedFontSize = stack.last?.1 ?? baseFontSize
                        }
                        stack.append((tagContent, adjustedFontSize))
                    }
                }
            } else {
                // Append characters to the current text buffer
                currentText.append(html[i])
                i = html.index(after: i)
            }
        }

        // Flush any remaining text
        if !currentText.isEmpty {
            result = result + applyStyles(currentText, stack: stack, baseFontSize: baseFontSize)
        }

        // Apply the outermost stack styles
        return result.font(.custom(customFontName, size: baseFontSize))
    }

    private func applyStyles(_ text: String, stack: [(String, CGFloat)], baseFontSize: CGFloat) -> Text {
        // Preserve trailing spaces
        let trimmedText = text.replacingOccurrences(of: "\u{00A0}", with: " ") // Non-breaking spaces
        var styledText = Text(trimmedText)

        // Apply styles in reverse stack order (from outermost to innermost tag)
        for (tag, fontSize) in stack.reversed() {
            switch tag {
            case "b":
                styledText = styledText.bold()
            default:
                styledText = styledText.font(.custom(customFontName, size: fontSize))
            }
        }

        return styledText
    }
}
