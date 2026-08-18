//
//  HabitPresets.swift
//  TrackerApp
//
//  Curated pickers for the Add/Edit Habit screen — keeps habit styling
//  simple (per plan.md) instead of a full custom color/emoji picker.
//

import Foundation

enum HabitPresets {
    /// The emoji assigned when a habit has none selected — a generic,
    /// habit-agnostic glyph rather than anything category-specific.
    static let defaultEmoji = "💡"

    /// Quick-pick shortlist shown in the Add/Edit Habit grid (3 rows at
    /// 6/row) — kept short since the same screen also lets you type any
    /// emoji from your keyboard for everything this list doesn't cover.
    static let emojis = [
        defaultEmoji, "🏃‍♀️", "🧘‍♀️", "🥗", "💧", "😴",
        "📚", "💻", "🎯", "🧹", "🎨", "❤️",
        "🙏", "🦷", "💊", "🚴‍♀️", "🎸", "🌿",
    ]

    /// Hex strings for the habit-card background — soft/pastel tints so
    /// dark text stays legible on top of them.
    static let colors = [
        "#DCE4FF", // light blue
        "#D9F5E3", // light green
        "#FFE1D6", // light coral
        "#F2E4D2", // light tan
        "#E7E1FF", // light purple
        "#FFDCE1", // light pink/red
        "#D7F5F2", // light teal
        "#E4EAFB", // light periwinkle
    ]
}
