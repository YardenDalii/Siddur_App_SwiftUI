//
//  NotificationHandler.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 04/04/2024.
//

import Foundation
import UserNotifications
import UIKit
import Combine



class NotificationManager:  NSObject, UNUserNotificationCenterDelegate {
    static let instance = NotificationManager()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    
    func scheduleTestNotification() {
        let title = "Test Notification"
        let body = "This is a test notification body."
        let identifier = "testNotification"
        
        // Schedule for 1 minute from now
        let time = Date().addingTimeInterval(60) // 60 seconds from now
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        
        dateComponents.second = 0
        
        scheduleNotification(title: title, body: body, dateComponents: dateComponents, identifier: identifier)
    }
    
    
    func scheduleNotification(title: String, body: String, dateComponents: DateComponents, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Time
//        let timeInterval = 10
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeUnterval, repeats: false)
        
        // Calendar
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Successfully scheduled notification.")
            }
        }
        
        // Location
//        let locationManager = LocationManager()
//
//        locationManager.locationUpdated = { location in
//            print("Current location is: \(location)")
//            let coordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//            
//            let region = CLCircularRegion(center: coordinates, radius: 100, identifier: UUID().uuidString)
//            
//            let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
//            
//            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//            
//            // Schedule the notification
//            UNUserNotificationCenter.current().add(request) { error in
//                if let error = error {
//                    print("Error scheduling notification: \(error)")
//                } else {
//                    print("Successfully scheduled notification with location trigger.")
//                }
//            }
//        }
//
//        // Request the location, which will trigger the locationUpdated closure above
//        locationManager.requestLocation()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the notification response here (e.g., when user taps on the notification)
        completionHandler()
    }
    
}

