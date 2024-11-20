//
//  ContentView.swift
//  Siddur
//
//  Created by Yarden Dali on 26/03/2024.
//

import SwiftUI
import Hebcal
import WebKit


struct SiddurView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var locationManager: LocationManager
    
    @EnvironmentObject var siddurData: SiddurLoader

    
    @State private var isLoading = true
    
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                
                PrayersView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "text.book.closed.fill" : "text.book.closed")
                            .environment(\.symbolVariants, .none)
                        Text("Siddur")
                    }
                    .tag(0)
                
                
                TehillimView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "books.vertical.fill" : "books.vertical")
                            .environment(\.symbolVariants, .none)
                        Text("TEHILLIM_LOC_STRING")
                    }
                    .tag(1)
                
                ZemanimView()
                    .tabItem{
                        Image(systemName: selectedTab == 2 ? "deskclock.fill" : "deskclock")
                            .environment(\.symbolVariants, .none)
                        Text("ZEMANIM")
                    }
                    .tag(2)
                
                
                SettingsView()
                    .tabItem {
                        Image(systemName: selectedTab == 3 ? "gearshape.fill" : "gearshape")
                            .environment(\.symbolVariants, .none)
                        Text("SETTINGS_LOC_STRING")
                        
                    }
                    .tag(3)
                
            }
        }
        .onAppear {
            locationManager.requestLocation()
            if let location = locationManager.currentLocation {
                print("Latitude: \(location.latitude), Longitude: \(location.longitude)")
            }
        }
    }
}


class SelectedPrayerModel: ObservableObject {
    @Published var index: Int = 0
}

// NSLocalizedString(, comment: "")


struct PrayersView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var siddurLoader = SiddurLoader()
    @State private var sections: [String: [String]] = PrayerSections

    var body: some View {
        NavigationStack {
            List {
                ForEach(sections.keys.sorted(), id: \.self) { sectionTitle in
                    prayerSection(
                        title: NSLocalizedString(sectionTitle, comment: ""),
                        prayerTitles: sections[sectionTitle] ?? []
                    )
                }
            }
            .background(
                Image("pageBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .scrollContentBackground(.hidden)
            .navigationTitle("Siddur")
            .navigationBarItems(trailing: Text("Mizrach"))
            .onAppear {
                siddurLoader.loadJSON()
            }
        }
    }

    @ViewBuilder
    private func prayerSection(title: String, prayerTitles: [String]) -> some View {
        Section(header: Text(title).bold()) {
            ForEach(prayerTitles, id: \.self) { prayerTitle in
                if let prayer = siddurLoader.siddur.first(where: { $0.title == prayerTitle }) {
                    NavigationLink(destination: PrayerPageView(prayerID: prayer.id, prayers: siddurLoader.siddur)) {
                        Text(NSLocalizedString(prayer.title, comment: ""))
                    }
                }
            }
        }
    }
}



#Preview {
    SiddurView()
        .environmentObject(LocationManager())
        .environmentObject(AppSettings())
        .environmentObject(SiddurLoader())
}
