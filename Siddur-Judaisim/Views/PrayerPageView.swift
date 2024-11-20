//
//  PrayerPageView.swift
//  Siddur
//
//  Created by Yarden Dali on 28/03/2024.
//

import SwiftUI
import UIKit



struct PrayerPageView: View {
    @EnvironmentObject var appSettings: AppSettings

    var prayerID: UUID
    var prayers: [Prayer]

    @State private var scrollToPartIndex: String? = nil

    var body: some View {
        NavigationView {
            if let prayer = prayers.first(where: { $0.id == prayerID }) {
                PrayerDetailView(prayer: prayer, scrollToPart: $scrollToPartIndex)
            } else {
                Text(NSLocalizedString("PRAYER_NOT_FOUND", comment: ""))
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .navigationBarTitle(NSLocalizedString(prayers.first(where: { $0.id == prayerID })!.title, comment: ""), displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                textSizeAdjustmentMenu
                partsMenu // Menu for part selection
            }
        }
    }

    private var textSizeAdjustmentMenu: some View {
        Menu {
            Stepper("\(NSLocalizedString("TEXT_SIZE_LOC_STRING", comment: "")): \(Int(appSettings.textSize))", value: $appSettings.textSize, step: 1)

            Button(action: { appSettings.textSize = 23.0 }) {
                Text(NSLocalizedString("RESET_TO_DEFAULT", comment: ""))
            }
        } label: {
            Label("TEXT_SIZE_LOC_STRING", systemImage: "textformat.size")
        }
    }

    private var partsMenu: some View {
        Menu {
            if let prayer = prayers.first(where: { $0.id == prayerID }) {
                ForEach(prayer.prayers) { section in
                    Button(action: {
                        scrollToPartIndex = section.title
                    }) {
                        Text(NSLocalizedString(section.title, comment: ""))
                    }
                }
            }
        } label: {
            Label("PRAYER_PARTS_LOC", systemImage: "list.bullet")
        }
    }
}

struct PrayerDetailView: View {
    var prayer: Prayer
    @EnvironmentObject var appSettings: AppSettings
    @Binding var scrollToPart: String? // Binding to listen for part selection

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(prayer.prayers) { section in
                    VStack(alignment: .leading, spacing: 10) {
//                        DynamicStyledText(input: section.title) // Render section title
//                            .environmentObject(appSettings)
//                            .padding(.bottom, 5)

                        ForEach(section.text, id: \.self) { text in
                            DynamicStyledText(input: text, customFontName: "Guttman Drogolin")
                                .padding(.bottom, 5)
                        }
                    }
                    .padding()
                    .id(section.title) // Add ID to use for scrolling
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .background {
                Image("pageBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }
            .onChange(of: scrollToPart) { oldPart, part in
                if let part = part {
                    proxy.scrollTo(part, anchor: .top)
                    scrollToPart = nil // Reset after scrolling
                }
            }
        }
    }
}
