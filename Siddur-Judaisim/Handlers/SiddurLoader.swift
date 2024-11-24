//
//  SiddurLoader.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 22/11/2024.
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



let OrderedSectionKeys = ["DAILY_PRAYES_LOC", "POST_MEAL_BLESSING", "Holiday Prayers"]

let PrayerSections: [String: [String]] = [
    "DAILY_PRAYES_LOC": [
        "PREPARATORY_PRAYERS", "WEEKDAY_SHACHARIT", "ADDITIONS_FOR_SHACHARIT", "WEEKDAY_MINCHA", "WEEKDAY_ARVIT", "BEDTIME_SHEMA",  "THE_MIDNIGHT_RITE"
    ],
    "POST_MEAL_BLESSING": [
        "POST_MEAL_BLESSING", "AL_HAMIHYA", "BLESSINGS_ON_ENJOYMENTS"
    ],
    "Holiday Prayers": [
        "Purim", "Hanukkah", "Rosh Hodesh", "Counting of the Omer"
    ]
]




// Load raw JSON file from the app bundle
func loadRawJSONFile(fileName: String) -> Data? {
    guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
        print("File not found: \(fileName).json")
        return nil
    }

    do {
        return try Data(contentsOf: URL(fileURLWithPath: path))
    } catch {
        print("Error loading JSON file: \(error)")
        return nil
    }
}

/// Transform raw JSON data into an array of Prayer objects
func transformText(rawText: [String: Any], userPasuk: String) -> [Prayer] {
    var prayers = [Prayer]()

    for (prayerTitle, sectionContent) in rawText {
        guard let sectionDict = sectionContent as? [String: Any],
              let order = sectionDict["order"] as? [String] else {
            print("Missing or invalid order key for prayer:", prayerTitle)
            continue
        }

        let orderedSections = order.compactMap { sectionName -> PrayerSection? in
            guard let text = sectionDict[sectionName] as? [String] else {
                print("Section \(sectionName) missing or invalid in \(prayerTitle).")
                return nil
            }

            // Replace placeholder with user's pasuk
            let processedText = text.map { line in
                line.replacingOccurrences(of: "{user_pasuk}", with: userPasuk)
            }

            return PrayerSection(title: sectionName, text: processedText)
        }

        prayers.append(Prayer(title: prayerTitle, prayers: orderedSections))
    }

    return prayers
}

/// Load prayers based on filename and smartSiddur flag
func loadPrayers(fileName: String, smart: Bool, userPasuk: String) -> [Prayer] {
    let fullFileName = smart ? "Smart-\(fileName)" : fileName

    guard let jsonData = loadRawJSONFile(fileName: fullFileName) else {
        print("Error: Could not load JSON file \(fullFileName)")
        return []
    }

    do {
        if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
           let rawText = json["text"] as? [String: Any] {
            return transformText(rawText: rawText, userPasuk: userPasuk)
        } else {
            print("Error: Invalid JSON structure in \(fullFileName)")
            return []
        }
    } catch {
        print("Error decoding JSON: \(error)")
        return []
    }
}
