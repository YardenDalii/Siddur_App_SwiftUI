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

