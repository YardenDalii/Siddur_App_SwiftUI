//
//  SiddurLoader.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 22/11/2024.
//

import Foundation
import SwiftUI


// MARK: - Data Models

struct PrayerSection: Identifiable, Equatable {
    let id: String  // Stable ID derived from title
    let title: String
    let text: [String]

    static func == (lhs: PrayerSection, rhs: PrayerSection) -> Bool {
        lhs.id == rhs.id
    }
}

// Represents a prayer section with nested prayers or subsections
struct Prayer: Identifiable, Equatable {
    let id: String  // Stable ID derived from title
    let title: String
    let sections: [PrayerSection]

    static func == (lhs: Prayer, rhs: Prayer) -> Bool {
        lhs.id == rhs.id
    }
}


// MARK: - Section Definitions

let OrderedSectionKeys = ["DAILY_PRAYES_LOC", "POST_MEAL_BLESSING", "BRACHOT_LOC", "HOLIDAY_PRAYERS",]

let PrayerSections: [String: [String]] = [
    "DAILY_PRAYES_LOC": [
        "PREPARATORY_PRAYERS", "WEEKDAY_SHACHARIT", "ADDITIONS_FOR_SHACHARIT", "WEEKDAY_MINCHA", "WEEKDAY_ARVIT", "BEDTIME_SHEMA",  "THE_MIDNIGHT_RITE"
    ],
    "POST_MEAL_BLESSING": [
        "POST_MEAL_BLESSING", "AL_HAMIHYA", "BLESSINGS_ON_ENJOYMENTS"
    ],
    "BRACHOT_LOC": [
        "ASHER_YATZAR", "TRAVELER'S_PRAYER", "BLESSING_OF_THE_MOON", "MEZUZA"
    ],
    "HOLIDAY_PRAYERS": [
        "ROSH_HODESH", "FESTIVALS_PRAYERS", "PURIM", "HANUKKAH", "NISSAN", "COUNTING_OF_THE_OMER"
    ],

]


// MARK: - Prayer Cache (avoids re-parsing 3.5MB JSON on every tab switch)

actor PrayerCache {
    static let shared = PrayerCache()

    private var cache: [String: [Prayer]] = [:]

    func get(key: String) -> [Prayer]? {
        cache[key]
    }

    func set(key: String, prayers: [Prayer]) {
        cache[key] = prayers
    }

    func invalidate() {
        cache.removeAll()
    }

    func invalidate(key: String) {
        cache.removeValue(forKey: key)
    }
}


// MARK: - Loading Functions

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
        // Support sections with "order" key
        if let sectionDict = sectionContent as? [String: Any],
           let order = sectionDict["order"] as? [String] {

            let orderedSections = order.compactMap { sectionName -> PrayerSection? in
                guard let text = sectionDict[sectionName] as? [String] else {
                    print("Section \(sectionName) missing or invalid in \(prayerTitle).")
                    return nil
                }

                // Replace placeholder with user's pasuk
                let processedText = text.map { line in
                    line.replacingOccurrences(of: "{user_pasuk}", with: userPasuk)
                }

                return PrayerSection(id: "\(prayerTitle)_\(sectionName)", title: sectionName, text: processedText)
            }

            prayers.append(Prayer(id: prayerTitle, title: prayerTitle, sections: orderedSections))

        }
        // Support sections without "order" key (dict of arrays)
        else if let sectionDict = sectionContent as? [String: Any] {
            var orderedSections = [PrayerSection]()
            for (subKey, subValue) in sectionDict {
                if let text = subValue as? [String] {
                    let processedText = text.map { line in
                        line.replacingOccurrences(of: "{user_pasuk}", with: userPasuk)
                    }
                    orderedSections.append(PrayerSection(id: "\(prayerTitle)_\(subKey)", title: subKey, text: processedText))
                }
            }
            if !orderedSections.isEmpty {
                prayers.append(Prayer(id: prayerTitle, title: prayerTitle, sections: orderedSections))
            }
        }
        // Support plain array sections (single list of lines)
        else if let textArray = sectionContent as? [String] {
            let processedText = textArray.map { line in
                line.replacingOccurrences(of: "{user_pasuk}", with: userPasuk)
            }
            let section = PrayerSection(id: "\(prayerTitle)_main", title: prayerTitle, text: processedText)
            prayers.append(Prayer(id: prayerTitle, title: prayerTitle, sections: [section]))
        }
        else {
            print("Missing or invalid order key for prayer:", prayerTitle)
            continue
        }
    }

    return prayers
}

/// Load prayers synchronously (kept for backward compat, but prefer async version)
func loadPrayers(fileName: String, smart: Bool, userPasuk: String) -> [Prayer] {
    let fullFileName = smart ? "Smart-\(fileName)" : fileName

    guard let jsonData = loadRawJSONFile(fileName: fullFileName) else {
        print("Error: Could not load JSON file \(fullFileName)")
        return []
    }

    do {
        if let json = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String: Any],
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

/// Async prayer loading with caching — parses off main thread
func loadPrayersAsync(fileName: String, smart: Bool, userPasuk: String) async -> [Prayer] {
    let fullFileName = smart ? "Smart-\(fileName)" : fileName
    let cacheKey = "\(fullFileName)_\(userPasuk)"

    // Check cache first
    if let cached = await PrayerCache.shared.get(key: cacheKey) {
        return cached
    }

    // Parse on background thread
    let prayers: [Prayer] = await withCheckedContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
            let result = loadPrayers(fileName: fileName, smart: smart, userPasuk: userPasuk)
            continuation.resume(returning: result)
        }
    }

    // Cache the result
    await PrayerCache.shared.set(key: cacheKey, prayers: prayers)

    return prayers
}
