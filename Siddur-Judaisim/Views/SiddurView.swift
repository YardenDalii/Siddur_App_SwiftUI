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
    
//    @EnvironmentObject var siddurData: SiddurLoader

    
    @State private var isLoading = true
    
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                
                PrayersView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "text.book.closed.fill" : "text.book.closed")
                            .environment(\.symbolVariants, .none)
                        Text("SIDDUR_LOC")
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
    @State private var siddurData: [Prayer] = []
    @State private var sections: [String: [String]] = PrayerSections

    var body: some View {
        NavigationStack {
            List {
                ForEach(OrderedSectionKeys, id: \.self) { sectionTitle in
                    prayerSection(
                        title: NSLocalizedString(sectionTitle, comment: ""),
                        prayerTitles: sections[sectionTitle] ?? []
                    )
                }
            }
            .background(ImageBackgroundView())
            .scrollContentBackground(.hidden)
            .navigationTitle("SIDDUR_LOC")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    prayerVersionMenu
                }
            }
            .onAppear {
                // Load prayers when the view appears
                reloadPrayers()
            }
        }
    }

    /// Toolbar menu for selecting prayer versions
    private var prayerVersionMenu: some View {
        Menu {
            ForEach(PrayerVersion.allCases, id: \.self) { version in
                Button(action: {
                    // Update selected version and reload prayers
                    appSettings.selectedPrayerVersion = version
                    reloadPrayers()
                }) {
                    HStack {
                        Text(version.displayName)
                        if appSettings.selectedPrayerVersion == version {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        } label: {
            Text(NSLocalizedString(appSettings.selectedPrayerVersion.displayName, comment: ""))
                .bold()
                .foregroundStyle(CustomPalette.golden.color)
        }
    }

    /// Reload prayers based on user settings
    private func reloadPrayers() {
        siddurData = loadPrayers(
            fileName: appSettings.selectedPrayerVersion.fileName,
            smart: appSettings.smartSiddur,
            userPasuk: appSettings.userPasuk
        )
    }

    @ViewBuilder
    private func prayerSection(title: String, prayerTitles: [String]) -> some View {
        Section(header: Text(title).bold()) {
            ForEach(prayerTitles, id: \.self) { prayerTitle in
                if let prayer = siddurData.first(where: { $0.title == prayerTitle }) {
                    NavigationLink(destination: PrayerPageView(prayerID: prayer.id, prayers: siddurData)) {
                        Text(NSLocalizedString(prayer.title, comment: ""))
                    }
                }
            }
        }
    }
}


struct ImageBackgroundView: View {
    var body: some View {
        Image("pageBG")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}



#Preview {
    SiddurView()
        .environmentObject(LocationManager())
        .environmentObject(AppSettings())
//        .environmentObject(SiddurLoader())
}
