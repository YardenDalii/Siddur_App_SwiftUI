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



enum AppFont: String, CaseIterable {
    case system = "System"
    case timesNewRoman = "Times New Roman"
    case arial = "Arial"
    case courierNew = "Courier New"
    case helvetica = "Helvetica"

    // Custom fonts in your app project
    case guttmanDeogolin = "Guttman Drogolin"
    case guttmanVilnaB = "Guttman Vilna-Bold"

    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .timesNewRoman:
            return "Times New Roman"
        case .arial:
            return "Arial"
        case .courierNew:
            return "Courier New"
        case .helvetica:
            return "Helvetica"
        case .guttmanDeogolin:
            return "Guttman Drogolin"
        case .guttmanVilnaB:
            return "Guttman Vilna-Bold"
        }
    }

    var fontFileName: String? {
        switch self {
        case .system:
            return nil
        case .timesNewRoman, .arial, .courierNew, .helvetica:
            return nil
        case .guttmanDeogolin:
            return "Guttman Drogolin" // Replace with your actual font file name
        case .guttmanVilnaB:
            return "Guttman Vilna-Bold" // Replace with your actual font file name
        }
    }
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
    case lightBlue = "ADD8E6"
    case darkBlue = "08344c"
    
    
    case page = "fcf8e8"
    case hebcal = "f8f7f6"
    
    var color: Color {
        Color(hex: self.rawValue)
    }
    
    static func color(for name: String) -> Color {
        if let palette = CustomPalette(rawValue: name) {
            return palette.color
        }
        return .gray
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


var feedbackEmail = "yarden.dali11@gmail.com"



enum CalendarConstants {
    static let dayHeight: CGFloat = 48
    static let monthHeight: CGFloat = 48 * 5
}
