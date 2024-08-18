//
//  ContentView.swift
//  Siddur
//
//  Created by Yarden Dali on 26/03/2024.
//

import SwiftUI
import Hebcal


struct SiddurView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var locationManager: LocationManager
    
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





struct PrayersView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    var prayers = MockPray()
    
    var body: some View {
        NavigationStack {
            List {
                prayerSection(title: NSLocalizedString("DAILY_PRAYES_LOC", comment: ""), prayers: prayers.dailyPrayers)
                prayerSection(title: NSLocalizedString("MAZON_PRAYES_LOC", comment: ""), prayers: prayers.mazonPrayers)
            }
//            .listStyle(PlainListStyle())
            .background(
                Image("pageBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .scrollContentBackground(.hidden) // ***
            .navigationTitle("Siddur")
            .navigationBarItems(trailing: Text("Mizrach"))
        }
    }
    
    @ViewBuilder
    private func prayerSection(title: String, prayers: [Prayer]) -> some View {
        Section(header: Text(title).bold()) {
            ForEach(prayers) { prayer in
                NavigationLink(destination: PrayerPageView(prayerID: prayer.id, prayers: prayers)) {
                    Text(prayer.name)
                }
            }
        }
//        .listRowBackground(Color.white)
        
    }

}


class SelectedPrayerModel: ObservableObject {
    @Published var index: Int = 0
}

// NSLocalizedString(, comment: "")



#Preview {
    SiddurView()
        .environmentObject(LocationManager())
        .environmentObject(AppSettings())
    
}
