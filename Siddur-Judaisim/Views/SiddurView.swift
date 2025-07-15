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
    @State private var currentSection: String = OrderedSectionKeys.first ?? ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(OrderedSectionKeys, id: \.self) { sectionTitle in
                    prayerSection(
                        title: NSLocalizedString(sectionTitle, comment: ""),
                        prayerTitles: sections[sectionTitle] ?? [],
                        sectionTitle: sectionTitle
                    )
                }
            }
            .coordinateSpace(name: "prayerListScroll")
            .background(ImageBackgroundView())
            .scrollContentBackground(.hidden)
//            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavTitleView(title: "SIDDUR_LOC")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    prayerVersionMenu
                }
            }
            .onAppear {
                reloadPrayers()
                currentSection = OrderedSectionKeys.first ?? ""
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
    private func prayerSection(title: String, prayerTitles: [String], sectionTitle: String) -> some View {
        Section(header:
            ZStack(alignment: .leading) {
                Text(title).bold()
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            updateSectionIfNeeded(title: sectionTitle, y: geo.frame(in: .named("prayerListScroll")).minY)
                        }
                        .onChange(of: geo.frame(in: .named("prayerListScroll")).minY) { newY in
                            updateSectionIfNeeded(title: sectionTitle, y: newY)
                        }
                }
                .frame(height: 0)
            }
        ) {
            ForEach(prayerTitles, id: \.self) { prayerTitle in
                if let prayer = siddurData.first(where: { $0.title == prayerTitle }) {
                    NavigationLink(destination: PrayerPageView(prayerID: prayer.id, prayers: siddurData)) {
                        Text(NSLocalizedString(prayer.title, comment: ""))
                    }
                }
            }
        }
    }

    private func updateSectionIfNeeded(title: String, y: CGFloat) {
        if y < 80 && y > 0 && currentSection != title {
            currentSection = title
        }
    }
}



#Preview {
    SiddurView()
        .environmentObject(LocationManager())
        .environmentObject(AppSettings())
}
