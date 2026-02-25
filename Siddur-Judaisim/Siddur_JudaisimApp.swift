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

    @StateObject private var appSettings = AppSettings()
    @StateObject private var locationManager = LocationManager()

    init() {
//        setupAppearance()
//        NotificationManager.instance.requestAuthorization()
//        NotificationManager.instance.scheduleTestNotification()
    }

    var body: some Scene {
        WindowGroup {
            SiddurView()
                .preferredColorScheme(appSettings.colorSchemePreference)
                .environmentObject(appSettings)
                .environmentObject(locationManager)
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
    @Published var textSize: Double {
        didSet { UserDefaults.standard.set(textSize, forKey: "textSize") }
    }
    @Published var userPasuk: String {
        didSet { UserDefaults.standard.set(userPasuk, forKey: "userPasuk") }
    }

    // UI Preferences
    @Published var selectedFontName: String {
        didSet { UserDefaults.standard.set(selectedFontName, forKey: "selectedFontName") }
    }
    @Published var language: String = Locale.current.language.languageCode?.identifier ?? "en"

    // Appearance setting
    @Published var appearanceSetting: String {
        didSet { UserDefaults.standard.set(appearanceSetting, forKey: "appearanceSettingKey") }
    }

    var colorSchemePreference: ColorScheme? {
        switch appearanceSetting {
        case "dark": return .dark
        case "light": return .light
        default: return nil // system default
        }
    }

    // User's Selected Location
    @Published var selectedLatitude: Double {
        didSet { UserDefaults.standard.set(selectedLatitude, forKey: "selectedLatitude") }
    }
    @Published var selectedLongitude: Double {
        didSet { UserDefaults.standard.set(selectedLongitude, forKey: "selectedLongitude") }
    }
    @Published var selectedLocation: String {
        didSet { UserDefaults.standard.set(selectedLocation, forKey: "selectedLocation") }
    }

    // User's Prayer Version Preference
    @Published var smartSiddur: Bool {
        didSet { UserDefaults.standard.set(smartSiddur, forKey: "smartSiddur") }
    }

    @Published var selectedPrayerVersionRawValue: String {
        didSet { UserDefaults.standard.set(selectedPrayerVersionRawValue, forKey: "selectedPrayerVersionRawValue") }
    }

    // Computed property for PrayerVersion
    var selectedPrayerVersion: PrayerVersion {
        get {
            PrayerVersion(rawValue: selectedPrayerVersionRawValue) ?? .mizrah
        }
        set {
            selectedPrayerVersionRawValue = newValue.rawValue
        }
    }

    init() {
        let defaults = UserDefaults.standard
        self.textSize = defaults.object(forKey: "textSize") as? Double ?? 20
        self.userPasuk = defaults.string(forKey: "userPasuk") ?? ""
        self.selectedFontName = defaults.string(forKey: "selectedFontName") ?? "System"
        self.appearanceSetting = defaults.string(forKey: "appearanceSettingKey") ?? "light"
        self.selectedLatitude = defaults.object(forKey: "selectedLatitude") as? Double ?? 0.0
        self.selectedLongitude = defaults.object(forKey: "selectedLongitude") as? Double ?? 0.0
        self.selectedLocation = defaults.string(forKey: "selectedLocation") ?? ""
        self.smartSiddur = defaults.bool(forKey: "smartSiddur")
        self.selectedPrayerVersionRawValue = defaults.string(forKey: "selectedPrayerVersionRawValue") ?? PrayerVersion.mizrah.rawValue
    }
}
