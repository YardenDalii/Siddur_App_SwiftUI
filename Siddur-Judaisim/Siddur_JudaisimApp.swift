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
        setupAppearance()
        NotificationManager.instance.requestAuthorization()
        NotificationManager.instance.scheduleTestNotification()
    }
    
    var body: some Scene {
        WindowGroup {
            SiddurView()
                .preferredColorScheme(.light)
                .environmentObject(AppSettings())
                .environmentObject(LocationManager())
                .environmentObject(SiddurLoader())
        }
        //        CarPlayScene()
    }
    
    
    private func setupAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        let tabBarAppearance = UITabBarAppearance()
        
        let accentColor = UIColor(CustomPalette.golden.color)
        
        // Always use dark mode colors for UI components
        navigationBarAppearance.backgroundColor = UIColor(CustomPalette.darkBrown.color)
        tabBarAppearance.backgroundColor = UIColor(CustomPalette.darkBrown.color)
        
        // Set the accent color
        
        
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
    // App User Preferences
    @Published var currentDate = Date()
    @AppStorage("textSize") var textSize: Double = 16
    @AppStorage("userPasuk") var userPasuk: String = ""
    //    @AppStorage("currentLocation") var userLocation: String
    @Published var language: String = Locale.current.language.languageCode?.identifier ?? "en"
}

