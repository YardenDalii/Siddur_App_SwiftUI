//
//  FontSelectionView.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 22/11/2024.
//

import SwiftUI

struct FontSelectionView: View {
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        HStack {
            Text("Abcde")
                .font(.custom(appSettings.selectedFontName, size: 60))
            Text("אבגדה")
                .font(.custom(appSettings.selectedFontName, size: 60))
        }
        .padding(.top, 30)
        .background(Image("pageBG"))
        List {
            ForEach(AppFont.allCases, id: \.self) { font in
                FontSelectionRow(font: font, isSelected: appSettings.selectedFontName == font.rawValue) {
                    appSettings.selectedFontName = font.rawValue
                }
            }
        }
        .background(ImageBackgroundView())
        .scrollContentBackground(.hidden)
//        .navigationTitle("CHOOSE_FONT_LOC")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("CHOOSE_FONT_LOC")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
//                            .foregroundStyle(CustomPalette.golden.color)
                }
            }
        }
    }
}


struct FontSelectionRow: View {
    var font: AppFont
    var isSelected: Bool
    var onSelect: () -> Void

    var body: some View {
        Button {
            onSelect()
        } label: {
            HStack {
                Text(font.displayName)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding(.leading)
            .contentShape(Rectangle())
        }
        .foregroundStyle(.primary)
    }
}


#Preview {
    FontSelectionView()
        .environmentObject(AppSettings())
}
