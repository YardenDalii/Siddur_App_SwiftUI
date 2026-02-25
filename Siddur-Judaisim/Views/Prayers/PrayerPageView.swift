//
//  PrayerPageView.swift
//  Siddur
//
//  Created by Yarden Dali on 28/03/2024.
//

import SwiftUI

struct PrayerPageView: View {
    @EnvironmentObject var appSettings: AppSettings

    var prayerID: String
    var prayers: [Prayer]

    @State private var scrollToPartIndex: String? = nil

    var body: some View {
        NavigationStack {
            if let prayer = prayers.first(where: { $0.id == prayerID }) {
                PrayerDetailView(prayer: prayer, scrollToPart: $scrollToPartIndex)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            VStack(spacing: 1) {
                                Text(NSLocalizedString(prayer.title, comment: ""))
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
            //                            .foregroundStyle(CustomPalette.golden.color)
                            }
                        }

                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            textSizeAdjustmentMenu
                            partsMenu
                        }
                    }
            } else {
                Text(NSLocalizedString("PRAYER_NOT_FOUND_LOC", comment: ""))
                    .font(.headline)
                    .foregroundColor(.gray)
                    .navigationTitle("") // Empty title for consistency
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .background(ImageBackgroundView())
    }


    private var textSizeAdjustmentMenu: some View {
        Menu {
            Stepper(NSLocalizedString("TEXT_SIZE_LOC_STRING", comment: "") + ": \(Int(appSettings.textSize))", value: $appSettings.textSize, step: 1)

            Button {
                appSettings.textSize = 20.0
            } label: {
                Text(NSLocalizedString("RESET_TO_DEFAULT", comment: ""))
            }
        } label: {
            Label(NSLocalizedString("TEXT_SIZE_LOC_STRING", comment: ""), systemImage: "textformat.size")
        }
    }

    private var partsMenu: some View {
        Menu {
            if let prayer = prayers.first(where: { $0.id == prayerID }) {
                ForEach(prayer.sections) { section in
                    Button {
                        scrollToPartIndex = section.title
                    } label: {
                        Text(NSLocalizedString(section.title, comment: ""))
                    }
                }
            }
        } label: {
            Label(NSLocalizedString("PRAYER_PARTS_LOC", comment: ""), systemImage: "list.bullet")
        }
    }
}

struct PrayerDetailView: View {
    var prayer: Prayer
    @EnvironmentObject var appSettings: AppSettings
    @Binding var scrollToPart: String?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(prayer.sections) { section in
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(section.text.enumerated()), id: \.offset) { index, text in
                            DynamicStyledText(input: text, customFontName: appSettings.selectedFontName)
                                .padding(.bottom, 8)
                        }
                    }
                    .padding()
                    .id(section.title)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .background(ImageBackgroundView())
            .onChange(of: scrollToPart) { oldValue, newValue in
                if let part = newValue {
                    proxy.scrollTo(part, anchor: .top)
                    scrollToPart = nil
                }
            }
        }
        .background(ImageBackgroundView())

    }
}
