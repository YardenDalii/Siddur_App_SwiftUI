//
//  Utilities.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 10/04/2024.
//

import Foundation
import SwiftUI

func loadContent(fileName: String) -> NSAttributedString? {
    guard let path = Bundle.main.path(forResource: fileName, ofType: "txt"),
          let string = try? String(contentsOfFile: path, encoding: .utf8) else {
        
        return nil //NSAttributedString(string: "nocontent")
    }
    
    return NSAttributedString(string: string)
}


enum CustomPalette: String {
    case black = "25343B"
    case cream = "E0DCCD"
    case darkGray = "6B7F7F"
    case darkBrown = "594A3A"
    case brown = "7D674B"
    case lightBrown = "97856D"
    case lightGray = "9EAAA5"
    case golden = "B09C7B"
    case blue = "419EAE"
    case darkBlue = "08344c"
    
    
    case page = "fcf8e8"
    case hebcal = "f8f7f6"
    
    var color: Color {
        Color(hex: self.rawValue)
    }
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
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
//        return applyStylesToEntireResult(result, stack: stack, baseFontSize: baseFontSize)
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
