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
    @State private var selectedPrayerIndex = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedPrayerIndex) {
                ForEach(Array(prayers.enumerated()), id: \.element.id) { index, prayer in
                    PrayerDetailView(prayer: prayer)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    selectedPrayerIndex = prayers.firstIndex(where: { $0.id == prayerID }) ?? 0
                }
            }
        }
        .navigationBarTitle(NSLocalizedString(prayers[selectedPrayerIndex].name, comment: ""), displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                textSizeAdjustmentMenu
            }
        }
    }
    
    private var textSizeAdjustmentMenu: some View {
        Menu {
            Stepper("\(NSLocalizedString("TEXT_SIZE_LOC_STRING", comment: "")): \(Int(appSettings.textSize))", value: $appSettings.textSize, step: 1)
            
            Button(action: { appSettings.textSize = 20.0 }) {
                Text(NSLocalizedString("RESET_TO_DEFAULT", comment:""))
            }
        } label: {
            Label("TEXT_SIZE_LOC_STRING", systemImage: "textformat.size")
        }
    }
}



struct PrayerDetailView: View {
    var prayer: Prayer
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ScrollView {
            if let textContent = loadContent(fileName: prayer.name) {
                Text(textContent.string)
//                    .font(.custom("Guttman Drogolin-Bold", size: textSize))
                    .font(.custom("Guttman Drogolin", size: appSettings.textSize))
//                    .font(.custom("Guttman Vilna-Bold", size: appSettings.textSize))
                    .padding()
                    .foregroundColor(CustomPalette.black.color)
//                    .multilineTextAlignment(.center)
                
            } else {
                Text("Failed to load the content.")
            }
        }
        .padding(.top, 1)
        .environment(\.layoutDirection, .rightToLeft)
        .background {
            Image("pageBG")
        }
        
    }
}


//struct PrayerDetailView: View {
//    var prayer: Prayer
//    @EnvironmentObject var appSettings: AppSettings
//
//    var body: some View {
//        ScrollView {
//            if let textContent = loadContent(fileName: prayer.name) {
//                AttributedTextView(attributedString: textContent, customFontName: "Guttman Drogolin", fontSize: appSettings.textSize)
//                    .font(.custom("Guttman Drogolin", size: appSettings.textSize))
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .padding()
//            } else {
//                Text("Failed to load the content.")
//                    .padding()
//            }
//        }
//        .padding(.top, 1)
//        .environment(\.layoutDirection, .rightToLeft)
//        .background {
//            Image("pageBG")
//        }
//    }
//}


#Preview {
    //    PrayerPageView(prayer: Prayer(name:"template"))
    PrayerPageView(prayerID: UUID(), prayers: MockPray().dailyPrayers).environmentObject(AppSettings())
    
}
