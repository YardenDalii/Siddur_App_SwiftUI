//
//  UtilityViews.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 14/07/2025.
//
import SwiftUI

struct ImageBackgroundView: View {
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                Image("pageBG")
                    .resizable()
                    .scaledToFill()
                    .backgroundExtensionEffect()
            } else {
                Image("pageBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
        }
    }
}


struct NavTitleView: View {
    
    var title: String
    var section: String?
    
    var body: some View {
        VStack(spacing: 1) {
            Text(NSLocalizedString(title, comment: ""))
                .font(.system(size: 28, weight: .bold, design: .rounded))
//                            .foregroundStyle(CustomPalette.golden.color)
            Text(NSLocalizedString(section ?? "", comment: ""))
                .font(.caption)
                .foregroundColor(.secondary)
                .transition(.opacity)
        }
    }
}
