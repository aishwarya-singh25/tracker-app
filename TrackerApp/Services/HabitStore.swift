//
//  HabitStore.swift
//  TrackerApp
//
//  Fetches habits + recent logs once per sign-in/app-resume and keeps them
//  in memory. Every toggle writes to Supabase immediately with an
//  optimistic local update (rolled back if the write fails). No realtime
//  subscription — this is a single-user app, so fetch-on-load is enough.
//

import Combine
import Foundation
import Supabase

@MainActor
final class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    /// habit.id -> set of local calendar days it was completed on.
    @Published var completedDays: [UUID: Set<Date>] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let client = SupabaseService.client
    /// How far back to load logs for — enough for streak calculations to
    /// have real headroom (the calculator itself caps at ~2 years, but we
    /// don't need to fetch that much for a habit tracker's "current streak").
    private let logsLookbackDays = 120

    func loadAll(userId: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            async let habitsTask: [Habit] = client
                .from("habits")
                .select()
                .eq("user_id", value: userId)
                .is("archived_at", value: nil)
                .order("sort_order", ascending: true)
                .execute()
                .value

            let cutoff = Calendar.habitCalendar.date(byAdding: .day, value: -logsLookbackDays, to: Date()) ?? Date()
            async let logsTask: [HabitLog] = client
                .from("habit_logs")
                .select()
                .eq("user_id", value: userId)
                .gte("log_date", value: DayKey.string(from: cutoff))
                .execute()
                .value

            let (fetchedHabits, fetchedLogs) = try await (habitsTask, logsTask)
            habits = fetchedHabits
            completedDays = Self.groupLogsByHabit(fetchedLogs)
        } catch {
            errorMessage = "Couldn't load your habits. Check your connection and try again."
        }
        isLoading = false
    }

    private static func groupLogsByHabit(_ logs: [HabitLog]) -> [UUID: Set<Date>] {
        var result: [UUID: Set<Date>] = [:]
        for log in logs {
            guard let day = DayKey.date(from: log.logDate) else { continue }
            result[log.habitId, default: []].insert(day)
        }
        return result
    }

    func isCompleted(_ habit: Habit, on date: Date) -> Bool {
        let day = Calendar.habitCalendar.startOfDay(for: date)
        return completedDays[habit.id]?.contains(day) ?? false
    }

    func streak(for habit: Habit) -> Int {
        StreakCalculator.currentStreak(completedDays: completedDays[habit.id] ?? [])
    }

    func habits(in block: TimeBlock) -> [Habit] {
        habits.filter { $0.timeBlock == block }.sorted { $0.sortOrder < $1.sortOrder }
    }

    /// All habits across every time block, in the same Morning → Night,
    /// sort_order-within-block order shown on the Today screen — used
    /// anywhere else (e.g. Streaks) that lists habits together.
    var orderedHabits: [Habit] {
        TimeBlock.allCases.flatMap { habits(in: $0) }
    }

    /// Toggles a habit's completion for the given day, writing straight to
    /// Supabase. Un-checking deletes that day's log row rather than storing
    /// a false/undone state.
    func toggleCompletion(_ habit: Habit, on date: Date, userId: UUID) async {
        let day = Calendar.habitCalendar.startOfDay(for: date)
        let wasCompleted = isCompleted(habit, on: day)

        // Optimistic update.
        if wasCompleted {
            completedDays[habit.id]?.remove(day)
        } else {
            completedDays[habit.id, default: []].insert(day)
        }

        do {
            if wasCompleted {
                try await client
                    .from("habit_logs")
                    .delete()
                    .eq("habit_id", value: habit.id)
                    .eq("log_date", value: DayKey.string(from: day))
                    .execute()
            } else {
                let newLog = NewHabitLog(habit_id: habit.id, user_id: userId, log_date: DayKey.string(from: day))
                try await client
                    .from("habit_logs")
                    .insert(newLog)
                    .execute()
            }
        } catch {
            // Roll back the optimistic update.
            if wasCompleted {
                completedDays[habit.id, default: []].insert(day)
            } else {
                completedDays[habit.id]?.remove(day)
            }
            errorMessage = "Couldn't save that — check your connection and try again."
        }
    }

    func addHabit(name: String, emoji: String, color: String, timeBlock: TimeBlock, userId: UUID) async {
        let nextSortOrder = habits(in: timeBlock).count
        let newHabit = NewHabit(
            user_id: userId,
            name: name,
            emoji: emoji,
            color: color,
            time_block: timeBlock.rawValue,
            sort_order: nextSortOrder
        )
        do {
            let created: Habit = try await client
                .from("habits")
                .insert(newHabit)
                .select()
                .single()
                .execute()
                .value
            habits.append(created)
        } catch {
            errorMessage = "Couldn't save the new habit — check your connection and try again."
        }
    }

    /// Updates a habit's name/icon/color, and optionally moves it to a
    /// different time block (edited via the Edit sheet). Moving to a new
    /// block appends it to the end of that block's order.
    func updateHabit(_ habit: Habit, name: String, emoji: String, color: String, timeBlock: TimeBlock) async {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        let previousHabits = habits

        let movedBlock = habit.timeBlock != timeBlock
        let newSortOrder = movedBlock ? habits(in: timeBlock).count : habit.sortOrder

        habits[index].name = name
        habits[index].emoji = emoji
        habits[index].color = color
        habits[index].timeBlock = timeBlock
        habits[index].sortOrder = newSortOrder

        let payload = HabitUpdate(
            name: name, emoji: emoji, color: color,
            time_block: timeBlock.rawValue, sort_order: newSortOrder
        )
        do {
            try await client
                .from("habits")
                .update(payload)
                .eq("id", value: habit.id)
                .execute()
        } catch {
            habits = previousHabits
            errorMessage = "Couldn't save that change — check your connection and try again."
        }
    }

    /// Reorders habits within a single time block (drag-to-reorder in the
    /// UI), reassigning sequential `sort_order` values and persisting them.
    func reorder(in block: TimeBlock, from source: IndexSet, to destination: Int, userId: UUID) async {
        let previousHabits = habits

        var blockHabits = habits(in: block)
        let moving = source.map { blockHabits[$0] }
        for index in source.sorted(by: >) {
            blockHabits.remove(at: index)
        }
        let adjustedDestination = destination - source.filter { $0 < destination }.count
        blockHabits.insert(contentsOf: moving, at: adjustedDestination)

        for (index, habit) in blockHabits.enumerated() {
            blockHabits[index].sortOrder = index
        }

        // Splice the reordered block back into the full habits array.
        var otherHabits = habits.filter { $0.timeBlock != block }
        otherHabits.append(contentsOf: blockHabits)
        habits = otherHabits

        do {
            for habit in blockHabits {
                try await client
                    .from("habits")
                    .update(["sort_order": habit.sortOrder])
                    .eq("id", value: habit.id)
                    .execute()
            }
        } catch {
            habits = previousHabits
            errorMessage = "Couldn't save the new order — check your connection and try again."
        }
    }

    /// Soft-deletes a habit (sets archived_at) rather than a hard delete —
    /// reversible, and keeps historical logs intact.
    func archiveHabit(_ habit: Habit) async {
        let previousHabits = habits
        habits.removeAll { $0.id == habit.id }
        do {
            try await client
                .from("habits")
                .update(["archived_at": ISO8601DateFormatter().string(from: Date())])
                .eq("id", value: habit.id)
                .execute()
        } catch {
            habits = previousHabits
            errorMessage = "Couldn't remove that habit — check your connection and try again."
        }
    }
}
