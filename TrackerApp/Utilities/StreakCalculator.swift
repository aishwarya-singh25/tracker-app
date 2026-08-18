//
//  StreakCalculator.swift
//  TrackerApp
//
//  Streak rule (see plan.md): walk backward week by week (Monday–Sunday)
//  from today. A week "counts" — and the walk continues into the prior
//  week — as long as at most 2 of its (already-happened) days were missed.
//  The streak is the total number of actually-completed days across all
//  qualifying weeks; hitting a week with more than 2 misses stops the walk.
//

import Foundation

enum StreakCalculator {
    static func currentStreak(
        completedDays: Set<Date>,
        today: Date = Date(),
        calendar: Calendar = .habitCalendar,
        maxWeeksToScan: Int = 104 // safety cap (~2 years) so this can't run away
    ) -> Int {
        var streak = 0
        var weekCursor = today // the last day of the week we're currently examining

        for _ in 0..<maxWeeksToScan {
            let weekStart = calendar.startOfWeek(containing: weekCursor)
            let weekEndForCounting = min(weekCursor, today)
            let daysThatHappened = calendar.days(from: weekStart, through: weekEndForCounting)
            guard !daysThatHappened.isEmpty else { break }

            let completedInWeek = daysThatHappened.filter { completedDays.contains($0) }
            let misses = daysThatHappened.count - completedInWeek.count

            guard misses <= 2 else { break }

            streak += completedInWeek.count

            guard let dayBeforeThisWeek = calendar.date(byAdding: .day, value: -1, to: weekStart) else {
                break
            }
            weekCursor = dayBeforeThisWeek
        }

        return streak
    }
}
