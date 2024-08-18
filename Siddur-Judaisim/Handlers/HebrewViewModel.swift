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
    
    func fetchZmanim(latitude: Double, longitude: Double, userLocation: String = "None") {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = formatter.string(from: currentDate)
        
        
        let apiLatitude = "\(latitude)" //"31.7683"  // Example: Jerusalem
        let apiLongitude = "\(longitude)" //"35.2137" // Example: Jerusalem
        
        let urlString = "https://www.hebcal.com/zmanim?cfg=json&latitude=\(apiLatitude)&longitude=\(apiLongitude)&date=\(formattedDate)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let times = jsonResponse["times"] as? [String: String] {
                    let keysOfInterest = [
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
                    
                    var filteredTimes: [String: String] = [:]
                    
                    for key in keysOfInterest {
                        if let value = times[key] {
                            filteredTimes[key] = value
                        }
                    }
                    
                    var tempEventTimes: [(eventName: String, localTimeString: String, date: Date)] = []
                    
                    let inputFormatter = ISO8601DateFormatter()
                    inputFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
                    
                    let outputFormatter = DateFormatter()
                    outputFormatter.dateStyle = .none
                    outputFormatter.timeStyle = .short
                    outputFormatter.timeZone = TimeZone.current
                    
                    for (eventName, timeString) in filteredTimes {
                        if let date = inputFormatter.date(from: timeString) {
                            let localTimeString = outputFormatter.string(from: date)
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
                    
                    DispatchQueue.main.async {
                        self?.eventTimes = tempEventTimes
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    
    func fetchShabbatTimes(latitude: Double, longitude: Double) {
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
                
                
                DispatchQueue.main.async {
                    
                    self?.shabbatTimes = filteredItems
                    self?.parasha = shabbatTimes.items.first { $0.category == "parashat" }
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


func convertToHHMM(from dateString: String) -> String? {
    let inputFormatter = ISO8601DateFormatter()
    inputFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
    
    if let date = inputFormatter.date(from: dateString) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.timeZone = TimeZone.current
        return outputFormatter.string(from: date)
    } else {
        return nil
    }
}



extension DateFormatter {
    static var dayOfWeek: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }
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
