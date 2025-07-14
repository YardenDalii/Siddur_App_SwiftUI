//
//  Siddur_JudaisimApp.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 31/03/2024.
//

import SwiftUI
import CoreLocation


@main
struct Siddur_JudaisimApp: App {
    
    init() {
//        setupAppearance()
//        NotificationManager.instance.requestAuthorization()
//        NotificationManager.instance.scheduleTestNotification()
    }
    
    var body: some Scene {
        WindowGroup {
            SiddurView()
                .preferredColorScheme(.light)
                .environmentObject(AppSettings())
                .environmentObject(LocationManager())
//                .environmentObject(SiddurLoader())
        }
    }
    
    
    private func setupAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        let tabBarAppearance = UITabBarAppearance()
        
        let accentColor = UIColor(CustomPalette.golden.color)
        
        // Always use dark mode colors for UI components
        navigationBarAppearance.backgroundColor = UIColor(CustomPalette.darkBrown.color)
        tabBarAppearance.backgroundColor = UIColor(CustomPalette.darkBrown.color)
        
        // Adjust text color based on the system's appearance
        
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        navigationBarAppearance.titleTextAttributes = [.foregroundColor: accentColor]
//        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: accentColor]
        
        // Apply accent color to the tab bar items and buttons
        UITabBar.appearance().tintColor = accentColor
        UIBarButtonItem.appearance().tintColor = accentColor
        
        
        // Set the appearance for Tab Bar items
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = accentColor
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = accentColor
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: accentColor]
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accentColor]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
//        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(CustomPalette.lightBrown.color)

        
        // Trigger UI updates to apply the new appearance
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                window.rootViewController?.view.setNeedsLayout()
                window.rootViewController?.view.layoutIfNeeded()
            }
        }
    }
    
}



class AppSettings: ObservableObject {
    @Published var currentDate = Date()
    
    // App User Preferences
    @AppStorage("textSize") var textSize: Double = 16
    @AppStorage("userPasuk") var userPasuk: String = ""
    
    // UI Preferences
    @AppStorage("selectedFontName") var selectedFontName: String = "System" // Default to the system font
    @Published var language: String = Locale.current.language.languageCode?.identifier ?? "en"

    // User's Selected Location
    @AppStorage("selectedLatitude") var selectedLatitude: Double = 0.0
    @AppStorage("selectedLongitude") var selectedLongitude: Double = 0.0
    @AppStorage("selectedLocation") private var storedLocation: String = ""
        
    var selectedLocation: String {
        get { storedLocation }
        set {
            storedLocation = newValue
            objectWillChange.send() // Force state update
        }
    }

    // User's Prayer Version Preference
    @AppStorage("selectedPrayerVersionRawValue") private var selectedPrayerVersionRawValue: String = PrayerVersion.mizrah.rawValue
    @AppStorage("smartSiddur") var smartSiddur: Bool = false
    
    // Computed property for PrayerVersion
    var selectedPrayerVersion: PrayerVersion {
        get {
            PrayerVersion(rawValue: selectedPrayerVersionRawValue) ?? .mizrah
        }
        set {
            selectedPrayerVersionRawValue = newValue.rawValue
        }
    }
}
