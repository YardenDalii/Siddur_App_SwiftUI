//
//  PrayPage.swift
//  Siddur
//
//  Created by Yarden Dali on 27/03/2024.
//

import Foundation
import SwiftUI



struct PrayerSection: Identifiable {
    let id = UUID()
    let title: String
    let text: [String]
}

// Represents a prayer section with nested prayers or subsections
struct Prayer: Identifiable {
    let id = UUID()
    let title: String
    let prayers: [PrayerSection]
}



class SiddurLoader: ObservableObject {
    @Published var siddur: [Prayer] = []
    @State var appSettings = AppSettings() // Access user settings, including the custom sentence

    func loadJSON() {
        guard let jsonData = loadRawJSONFile(fileName: "SiddurEdotHaMizrach") else {
            print("Could not load JSON content.")
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
               let rawText = json["text"] as? [String: Any] {
                DispatchQueue.main.async {
                    self.siddur = self.transformText(rawText)
                }
                print("Siddur loaded successfully with \(self.siddur.count) prayers!")
            } else {
                print("Invalid JSON structure.")
            }
        } catch {
            print("Error parsing JSON:", error)
        }
    }

    private func transformText(_ rawText: [String: Any]) -> [Prayer] {
        var prayers = [Prayer]()

        for (prayerTitle, sectionContent) in rawText {
            guard let sectionDict = sectionContent as? [String: Any],
                  let order = sectionDict["order"] as? [String] else {
                print("Missing or invalid order key for prayer:", prayerTitle)
                continue
            }

            // Use the order array to sort and arrange sections
            let orderedSections = order.compactMap { sectionName -> PrayerSection? in
                guard let text = sectionDict[sectionName] as? [String] else {
                    print("Section \(sectionName) missing or invalid in \(prayerTitle).")
                    return nil
                }

                // Insert user's sentence if placeholder exists
                let processedText = text.map { line in
                    line.replacingOccurrences(of: "{user_pasuk}", with: appSettings.userPasuk)
                }

                return PrayerSection(title: sectionName, text: processedText)
            }

            prayers.append(Prayer(title: prayerTitle, prayers: orderedSections))
        }

        return prayers
    }

    private func loadRawJSONFile(fileName: String) -> Data? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("File not found: \(fileName).json")
            return nil
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return data
        } catch {
            print("Error loading JSON file:", error)
            return nil
        }
    }
}


var PrayerSections: [String: [String]] = [
    "DAILY_PRAYES_LOC": [
        "PREPARATORY_PRAYERS", "WEEKDAY_SHACHARIT", "ADDITIONS_FOR_SHACHARIT", "WEEKDAY_MINCHA", "WEEKDAY_ARVIT", "BEDTIME_SHEMA",  "THE_MIDNIGHT_RITE"
    ],
    "Fasting Prayers": [
        "Post Meal Blessing", "Al Hamihya", "Blessings on Enjoyments"
    ],
    "Holiday Prayers": [
        "Purim", "Hanukkah", "Rosh Hodesh", "Counting of the Omer"
    ]
]
/*
 "Daily Prayers": [
                 "Preparatory Prayers", "The Midnight Rite", "Weekday Shacharit",
                 "Weekday Mincha", "Weekday Arvit", "Additions for Shacharit", "Bedtime Shema"
             ],
             "Fasting Prayers": [
                 "Post Meal Blessing", "Al Hamihya", "Blessings on Enjoyments"
             ],
             "Holiday Prayers": [
                 "Purim", "Hanukkah", "Rosh Hodesh", "Counting of the Omer"
             ]
 */
