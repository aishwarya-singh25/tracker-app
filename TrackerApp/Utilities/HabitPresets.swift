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

    /// Hex strings for the habit-card background — muted mid-tones (between
    /// the original saturated hues and a too-light pastel) so dark text
    /// stays legible while the card still reads with real color.
    static let colors = [
        "#94A9FF", // blue
        "#86DEAF", // green
        "#FFAD97", // coral
        "#CDAD88", // tan
        "#B8A7FF", // purple
        "#F8989D", // pink/red
        "#8BDAD9", // teal
        "#9FBBF5", // periwinkle
    ]
}
