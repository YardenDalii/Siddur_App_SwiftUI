//
//  Zemanim.swift
//  Siddur
//
//  Created by Yarden Dali on 31/03/2024.
//

import Foundation
import Combine

class HebrewTimeModel: ObservableObject {

    @Published var eventTimes: [(eventName: String, localTimeString: String, date: Date)] = []
    @Published var shabbatTimes: [Event] = []
    @Published var parasha: Event?
    @Published var currentDate = Date()
    @Published var isLoading = false
    @Published var hasError = false

    // Cache for offline support — keyed by "lat_lon_date"
    private static var zmanimCache: [String: [(eventName: String, localTimeString: String, date: Date)]] = [:]
    private static var shabbatCache: [String: ([Event], Event?)] = [:]

    // Reusable formatters (avoid recreating per-call — significant perf gain)
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        f.timeZone = TimeZone.current
        return f
    }()

    private static let keysOfInterest = [
        "alotHaShacar",
        "misheyakirMachmir",
        "sunrise",
        "sofZmanShmaMGA",
        "sofZmanShma",
        "sofZmanTfillaMGA",
        "sofZmanTfilla",
        "chatzot",
        "minchaGedola",
        "minchaKetana",
        "plagHaMincha",
        "sunset",
        "tzeit7083deg",
        "tzeit72min",
        "chatzotNight"
    ]

    func fetchZmanim(latitude: Double, longitude: Double, userLocation: String = "None") {
        let formattedDate = Self.dateFormatter.string(from: currentDate)
        let cacheKey = "\(latitude)_\(longitude)_\(formattedDate)"

        // Check cache first (offline support)
        if let cached = Self.zmanimCache[cacheKey] {
            DispatchQueue.main.async {
                self.eventTimes = cached
            }
            return
        }

        let apiLatitude = "\(latitude)"
        let apiLongitude = "\(longitude)"

        let urlString = "https://www.hebcal.com/zmanim?cfg=json&latitude=\(apiLatitude)&longitude=\(apiLongitude)&date=\(formattedDate)"

        guard let url = URL(string: urlString) else { return }

        isLoading = true

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hasError = true
                }
                return
            }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let times = jsonResponse["times"] as? [String: String] {

                    var filteredTimes: [String: String] = [:]
                    for key in Self.keysOfInterest {
                        if let value = times[key] {
                            filteredTimes[key] = value
                        }
                    }

                    var tempEventTimes: [(eventName: String, localTimeString: String, date: Date)] = []

                    for (eventName, timeString) in filteredTimes {
                        if let date = Self.isoFormatter.date(from: timeString) {
                            let localTimeString = Self.timeFormatter.string(from: date)
                            tempEventTimes.append((eventName, localTimeString, date))
                        } else {
                            print("Error parsing time for \(eventName)")
                        }
                    }

                    tempEventTimes.sort(by: { $0.date < $1.date })

                    if !tempEventTimes.isEmpty {
                        let firstEvent = tempEventTimes.removeFirst()
                        tempEventTimes.append(firstEvent)
                    }

                    // Cache for offline
                    Self.zmanimCache[cacheKey] = tempEventTimes

                    DispatchQueue.main.async {
                        self.eventTimes = tempEventTimes
                        self.isLoading = false
                        self.hasError = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.hasError = true
                }
                print(error)
            }
        }.resume()
    }


    func fetchShabbatTimes(latitude: Double, longitude: Double) {
        let cacheKey = "shabbat_\(latitude)_\(longitude)"

        // Check cache first
        if let cached = Self.shabbatCache[cacheKey] {
            DispatchQueue.main.async {
                self.shabbatTimes = cached.0
                self.parasha = cached.1
            }
            return
        }

        let urlString = "https://www.hebcal.com/shabbat?cfg=json&latitude=\(latitude)&longitude=\(longitude)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            do {
                let shabbatTimes = try JSONDecoder().decode(ShabbatTimes.self, from: data)
                let filteredItems = shabbatTimes.items.filter { $0.category == "candles" || $0.category == "havdalah" }.map { item -> Event in
                    let localTimeString = convertToHHMM(from: item.date) ?? item.date
                    return Event(title: item.title, date: localTimeString, hebrew: item.hebrew, category: item.category)
                }
                let parasha = shabbatTimes.items.first { $0.category == "parashat" }

                // Cache for offline
                Self.shabbatCache[cacheKey] = (filteredItems, parasha)

                DispatchQueue.main.async {
                    self?.shabbatTimes = filteredItems
                    self?.parasha = parasha
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
}




struct Zmanim: Codable {
    var times: [String: String]
}



struct ShabbatTimes: Codable {
    let title: String
    let date: String
    let items: [Event]
}



struct Event: Codable {
    let title: String
    let date: String
    let hebrew: String
    let category: String?
}


// Reusable static formatters for convertToHHMM (avoid recreating per-call)
private let _hhmmInputFormatter: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
    return f
}()

private let _hhmmOutputFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    f.timeZone = TimeZone.current
    return f
}()

func convertToHHMM(from dateString: String) -> String? {
    if let date = _hhmmInputFormatter.date(from: dateString) {
        return _hhmmOutputFormatter.string(from: date)
    } else {
        return nil
    }
}



extension DateFormatter {
    static let dayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
}



/*
 alotHaShacar - עלות השחר
 misheyakirMachmir - זמן טלית ותפילין
 sunrise - הנץ החמה
 sofZmanShmaMGA - סוף זמן שמע (אברהם)
 sofZmanShma - סוף שמע (גרא)
 sofZmanTfillaMGA - סוף זמן תפילה (אברהם)
 sofZmanTfilla - סוף זמן תפילה (גרא)
 chatzot - חצות היום
 minchaGedola - מנחה גדולה
 minchaKetana - מנחה קטנה
 plagHaMincha - פלג (גרא)
 sunset - שקיעה
 tzeit7083deg - צאת הכוכבים
 tzeit72min - רבינו תם
 chatzotNight - חצות הלילה
 */
