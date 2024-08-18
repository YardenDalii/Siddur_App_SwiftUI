//
//  ZmanimWidget.swift
//  ZmanimWidget
//
//  Created by Yarden Dali on 04/04/2024.
//

import WidgetKit
import SwiftUI
import CoreLocation
import Hebcal
import Intents


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), zmanim: [("sunrise","01:01"), ("chatzot","02:02"), ("sunset","03:03"), ("chatzotNight","04:04")])//, locationManager: LocationManager())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), zmanim: [("event1","01:01"), ("event2","02:02"), ("event2","03:03"), ("event2","04:04")])//, locationManager: LocationManager())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            var entries: [SimpleEntry] = []
            
            let zmanimData = await fetchZmanim(keysOfInterest: ["sunrise", "chatzot", "sunset", "chatzotNight"])
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let currentDate = Date()
            for dayOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, zmanim: zmanimData)//, locationManager: LocationManager())
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    func fetchZmanim(keysOfInterest: [String]) async -> [(String, String)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = formatter.string(from: Date())
        
        let latitude = "31.7683"  // Example: Jerusalem
        let longitude = "35.2137" // Example: Jerusalem
        let urlString = "https://www.hebcal.com/zmanim?cfg=json&latitude=\(latitude)&longitude=\(longitude)&date=\(formattedDate)"
        
        guard let url = URL(string: urlString) else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let times = jsonResponse["times"] as? [String: String] {
                
                var filteredTimes: [String: String] = [:]
                
                for key in keysOfInterest {
                    if let value = times[key] {
                        filteredTimes[key] = value
                    }
                }
                
                let inputFormatter = ISO8601DateFormatter()
                inputFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
                
                let outputFormatter = DateFormatter()
                outputFormatter.dateStyle = .none
                outputFormatter.timeStyle = .short
                outputFormatter.timeZone = TimeZone.current
                
                var eventTimes: [(eventName: String, localTimeString: String)] = []
                
                for (eventName, timeString) in filteredTimes {
                    if let date = inputFormatter.date(from: timeString) {
                        let localTimeString = outputFormatter.string(from: date)
                        eventTimes.append((eventName, localTimeString))
                    } else {
                        print("Error parsing time for \(eventName)")
                    }
                }
                
                
                return eventTimes
            }
        } catch {
            print("Failed to fetch or decode Zmanim data:", error)
        }
        
        return []
    }
}



struct SimpleEntry: TimelineEntry {
    let date: Date
    let zmanim: [(eventName: String, eventTime: String)]
    //    let locationManager: LocationManager
}



struct ZmanimSmallWidgetView : View {
    
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Text("\(entry.date)")
        }
    }
}



struct ZmanimSmallWidget: Widget {
    let kind: String = "ZmanimSmallWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ZmanimSmallWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ZmanimSmallWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Zmanim-Widget")
        .description("WIDGET-DESC-TEXT")
        .supportedFamilies([.systemSmall])
    }
}



struct ZmanimMediumWidgetView : View {
    
    var entry: Provider.Entry
    
    //    @StateObject var locationManager:  LocationManager
    //    @StateObject var viewModel: HebrewTimeModel
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.gray.gradient)
            VStack {
                Text(HDate(date: entry.date, calendar: .current).render(lang: TranslationLang.he))
                    .font(.system(size:14))
                Divider()
                ForEach(entry.zmanim, id: \.eventName) { event in
                    HStack {
                        Text(NSLocalizedString(event.eventName, comment: "")).bold()
                        Spacer()
                        Text(event.eventTime)
                    }
                    .font(.system(size:12))
                }
            }
            //            if !self.viewModel.eventTimes.isEmpty {
            //                VStack {
            //                    Label("\(self.viewModel.parasha?.hebrew ?? "")", systemImage: "book.pages.fill")
            //                        .bold()
            //                        .foregroundStyle(.black)
            //                    Divider()
            //                    if !self.viewModel.shabbatTimes.isEmpty {
            //                        ForEach(self.viewModel.shabbatTimes, id: \.title) { item in
            //                            HStack {
            //                                Text(NSLocalizedString("\(item.category ?? "")", comment: "")).bold()
            //                                Spacer()
            //                                Text("\(item.date)")
            //                            }
            //                            .foregroundStyle(.black)
            //                            .padding(.top, 5)
            //                        }
            //                    } else {
            //                        Text("FETCHING_SHABBAT_TIMES")
            //                    }
            //                }
            //            } else {
            //                Text("cant load data")
            //            }
        }
        //        .onAppear {
        //            if let location = locationManager.currentLocation {
        //                viewModel.fetchShabbatTimes(latitude: location.latitude, longitude: location.longitude)
        //            }
        //        }
    }
}



struct ZmanimMediumWidget: Widget {
    let kind: String = "ZmanimMediumWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                //                ZmanimMediumWidgetView(entry: entry, locationManager: locationManager, viewModel: viewModel)
                ZmanimMediumWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                //                ZmanimMediumWidgetView(entry: entry, locationManager: locationManager, viewModel: viewModel)
                ZmanimMediumWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Zmanim-Widget")
        .description("WIDGET-DESC-TEXT")
        .supportedFamilies([.systemMedium])
    }
}



struct ZmanimInlineWidgetView : View {
    
    var entry: Provider.Entry
    
    var body: some View {
        if afterSunset{
            Text("\(formattedCurrentDate) • \(HDate(date: entry.date, calendar: .current).render(lang: TranslationLang.he))")
        } else {
            Text("\(formattedCurrentDate) • \(HDate(date: Calendar.current.date(byAdding: .day, value: 1, to: entry.date)!, calendar: .current).render(lang: TranslationLang.he))")
        }
    }
    
    var formattedCurrentDate: String {
        let date = Date() // This is your date object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        dateFormatter.locale = Locale.current // Use the device's current locale
        return dateFormatter.string(from: date)
    }
    
    var afterSunset: Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: entry.date)
        return hour < 20
    }
    //    var afterSunset: String {
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "yyyy-MM-dd"
    //        let formattedDate = formatter.string(from: currentDate)
    //
    //
    //        let apiLatitude = "\(latitude)" //"31.7683"  // Example: Jerusalem
    //        let apiLongitude = "\(longitude)" //"35.2137" // Example: Jerusalem
    //
    //        let urlString = "https://www.hebcal.com/zmanim?cfg=json&latitude=\(apiLatitude)&longitude=\(apiLongitude)&date=\(formattedDate)"
    //    }
}



struct ZmanimInlineWidget: Widget {
    let kind: String = "ZmanimInlineWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ZmanimInlineWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ZmanimInlineWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Zmanim-Widget")
        .description("WIDGET-DESC-TEXT")
        .supportedFamilies([.accessoryInline])
    }
}



#Preview(as: .systemSmall) {
    ZmanimSmallWidget()
} timeline: {
    SimpleEntry(date: .now, zmanim: [("event1","01:01"), ("event2","02:02"), ("event3","03:03"), ("event4","04:04"), ("event5","05:05")])//, locationManager: LocationManager())
}


#Preview(as: .systemMedium) {
    ZmanimMediumWidget()
} timeline: {
    SimpleEntry(date: .now, zmanim: [("event1","01:01"), ("event2","02:02"), ("event3","03:03"), ("event4","04:04"), ("event5","05:05")])//, locationManager: LocationManager())
}


#Preview(as: .accessoryInline) {
    ZmanimInlineWidget()
} timeline: {
    SimpleEntry(date: .now, zmanim: [("event1","01:01"), ("event2","02:02"), ("event3","03:03"), ("event4","04:04"), ("event5","05:05")])//, locationManager: LocationManager())
}
