//
//  Habit.swift
//  TrackerApp
//
//  Data models mirroring the `habits` and `habit_logs` tables in Supabase.
//  See supabase/schema.sql for the source of truth.
//

import Foundation

enum TimeBlock: String, CaseIterable, Codable, Identifiable {
    case morning
    case afternoon
    case evening
    case night

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }
}

struct Habit: Identifiable, Codable, Equatable {
    let id: UUID
    var userId: UUID
    var name: String
    var emoji: String
    var color: String          // hex string, e.g. "#4C6FFF"
    var timeBlock: TimeBlock
    var sortOrder: Int
    var archivedAt: Date?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case emoji
        case color
        case timeBlock = "time_block"
        case sortOrder = "sort_order"
        case archivedAt = "archived_at"
        case createdAt = "created_at"
    }
}

/// A single day's completion of a habit. One row per habit per day.
///
/// `logDate` is kept as a plain "yyyy-MM-dd" string rather than a `Date` —
/// it mirrors Postgres's `date` column exactly and sidesteps timezone
/// ambiguity (see `DayKey` for converting to/from a local calendar day).
struct HabitLog: Identifiable, Codable, Equatable {
    let id: UUID
    var habitId: UUID
    var userId: UUID
    var logDate: String
    var completedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case habitId = "habit_id"
        case userId = "user_id"
        case logDate = "log_date"
        case completedAt = "completed_at"
    }
}

/// Payload for creating a new habit — omits fields the database fills in
/// (`id`, `created_at`).
struct NewHabit: Encodable {
    let user_id: UUID
    let name: String
    let emoji: String
    let color: String
    let time_block: String
    let sort_order: Int
}

/// Payload for editing an existing habit's name/icon/color/time-block.
struct HabitUpdate: Encodable {
    let name: String
    let emoji: String
    let color: String
    let time_block: String
    let sort_order: Int
}

/// Payload for creating a new habit_log row (marking a habit done for a day).
struct NewHabitLog: Encodable {
    let habit_id: UUID
    let user_id: UUID
    let log_date: String
}
