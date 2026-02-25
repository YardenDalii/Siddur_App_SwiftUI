//
//  CalendarExtantion.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 01/08/2025.
//
import Foundation
import Hebcal

extension Calendar {

    // MARK: - Reusable formatters (avoid recreating per-call — significant perf gain)
    private static let dayNumberFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd"
        return f
    }()

    private static let dayLetterFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEEE"
        return f
    }()

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f
    }()

    // MARK: - Week Calculations (Hebrew week starts on Sunday / יום ראשון)

    static func nearestSunday(from date: Date = .now) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let daysToSubtract = (weekday - 1 + 7) % 7
        guard let theNearestSunday = calendar.date(byAdding: .day, value: -daysToSubtract, to: date) else {
            return date
        }

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: theNearestSunday)
        dateComponents.hour = 9
        dateComponents.minute = 0
        dateComponents.second = 0

        return Calendar.current.date(from: dateComponents) ?? theNearestSunday
    }

    static func currentWeek(from date: Date = .now) -> [Date] {
        let calendar = Calendar.current
        return (0...6).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: date)
        }
    }

    static func nextWeek(from date: Date = .now) -> [Date] {
        let calendar = Calendar.current
        return (1...7).compactMap { offset in
            calendar.date(byAdding: .day, value:  offset, to: date)
        }
    }

    static func previousWeek(from date: Date = .now) -> [Date] {
        let calendar = Calendar.current
        return (1...7).compactMap { offset in
            calendar.date(byAdding: .day, value: -(6 - offset + 2), to: date)
        }
    }

    // MARK: - Display Formatters

    static func dayNumber(from date: Date) -> String {
        dayNumberFormatter.string(from: date)
    }

    static func hebrewDayNumber(from date: Date) -> String {
        let hebrewCalendar = Calendar(identifier: .hebrew)
        let day = hebrewCalendar.component(.day, from: date)

        let hebrewLetters = [
            "א", "ב", "ג", "ד", "ה", "ו", "ז", "ח", "ט", "י",
            "יא", "יב", "יג", "יד", "טו", "טז", "יז", "יח", "יט", "כ",
            "כא", "כב", "כג", "כד", "כה", "כו", "כז", "כח", "כט", "ל"
        ]

        guard day >= 1 && day <= 30 else { return "" }
        return hebrewLetters[day - 1]
    }

    static func hebrewMonthAndYear(from date: Date) -> String {
        let hdate = HDate(date: date, calendar: .current)
        let fullHebrewDate = hdate.render(lang: TranslationLang.he)
        let components = fullHebrewDate.split(separator: " ")
        if components.count >= 3 {
            return components.dropFirst().joined(separator: " ")
        }
        return fullHebrewDate
    }

    static func dayLetter(from date: Date) -> String {
        dayLetterFormatter.string(from: date)
    }

    static func weekAndYear(from date: Date) -> String {
        let calendar = Calendar.current
        let weekNumber = calendar.component(.weekOfYear, from: date)
        let year = calendar.component(.year, from: date)
        return "\(weekNumber)-\(year)"
    }

    static func monthAndYear(from date: Date) -> String {
        let calendar = Calendar.current
        let month = monthFormatter.string(from: date)
        let year = calendar.component(.year, from: date)

        return "\(month) \(year)"
    }

    static func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month],  from: date1)
        let components2 = calendar.dateComponents([.year, .month], from: date2)
        return components1.year == components2.year && components1.month == components2.month
    }

}
