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

    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            Tab.init("SIDDUR_LOC", systemImage: selectedTab == 0 ? "text.book.closed.fill" : "text.book.closed", value: 0/*, role: <#T##TabRole?#>)*/) {
                PrayersView()
            }

            
            Tab.init("TEHILLIM_LOC_STRING", systemImage: selectedTab == 1 ? "books.vertical.fill" : "books.vertical", value: 1/*, role: .search*/) {
                TehillimView()
            }
            
            Tab.init("ZEMANIM", systemImage: selectedTab == 2 ? "deskclock.fill" : "deskclock", value: 2/*, role: <#T##TabRole?#>*/) {
                ZemanimView()
            }

            
            Tab.init("SETTINGS_LOC_STRING", systemImage: selectedTab == 3 ? "gearshape.fill" : "gearshape", value: 3/*, role: <#T##TabRole?#>*/) {
                SettingsView()
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    prayerVersionMenu
                }
            }
            .onAppear {
                reloadPrayers()
            }
        }
    }

    private var prayerVersionMenu: some View {
        Menu {
            ForEach(PrayerVersion.allCases, id: \.self) { version in
                Button {
                    appSettings.selectedPrayerVersion = version
                    reloadPrayers()
                } label: {
                    HStack {
                        Text(NSLocalizedString(version.displayName, comment: ""))
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

#Preview {
    SiddurView()
        .environmentObject(LocationManager())
        .environmentObject(AppSettings())
}
