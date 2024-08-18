//
//  PrayerPageView.swift
//  Siddur
//
//  Created by Yarden Dali on 28/03/2024.
//

import SwiftUI
import UIKit



struct PrayerPageView: View {
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
        .navigationBarTitle(prayers[selectedPrayerIndex].name, displayMode: .inline)
    }
}


struct PrayerDetailView: View {
    var prayer: Prayer
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ScrollView {
            Text(prayer.name) // Customize as needed
                .foregroundColor(CustomPalette.black.color)
            //            if let textContent = loadContent(fileName: prayer.name) {
            //                Text(textContent.string)
            ////                    .font(.custom("Guttman Drogolin-Bold", size: textSize))
            ////                    .font(.custom("Guttman Drogolin", size: textSize))
            //                    .font(.custom("Guttman Vilna-Bold", size: appSettings.textSize))
            //                    .padding()
            //                    .foregroundColor(CustomPalette.black.color)
            //
            //                
            //            } else {
            //                Text("Failed to load the content.")
            //            }
        }
        .background {
            Image("pageBG")
        }
    }
}


#Preview {
    //    PrayerPageView(prayer: Prayer(name:"template"))
    PrayerPageView(prayerID: UUID(), prayers: MockPray().dailyPrayers)
    
}
