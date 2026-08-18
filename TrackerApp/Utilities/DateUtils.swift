//
//  DateUtils.swift
//  TrackerApp
//
//  Day-boundary helpers. "A day" always means a local calendar day
//  (midnight to midnight in the device's current timezone).
//

import Foundation

/// Converts between `Date` and the "yyyy-MM-dd" strings stored in
/// `habit_logs.log_date`.
enum DayKey {
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = .current
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }

    static func date(from string: String) -> Date? {
        formatter.date(from: string)
    }
}

extension Calendar {
    /// A Gregorian calendar with Monday as the first day of the week, used
    /// consistently for all "which week is this day in" logic (streaks and
    /// the date strip).
    static var habitCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // Monday
        cal.timeZone = .current
        return cal
    }

    /// The Monday that starts the week containing `date`.
    func startOfWeek(containing date: Date) -> Date {
        let day = startOfDay(for: date)
        let weekday = component(.weekday, from: day) // 1 = Sunday ... 7 = Saturday
        let mondayBasedOffset = (weekday + 5) % 7     // Monday = 0 ... Sunday = 6
        return self.date(byAdding: .day, value: -mondayBasedOffset, to: day) ?? day
    }

    /// All calendar days from `start` through `end`, inclusive.
    func days(from start: Date, through end: Date) -> [Date] {
        let start = startOfDay(for: start)
        let end = startOfDay(for: end)
        guard start <= end else { return [] }

        var result: [Date] = []
        var current = start
        while current <= end {
            result.append(current)
            guard let next = date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return result
    }
}
