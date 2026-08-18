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

    /// Curated icon set for habits. Any human/person glyph uses the female
    /// presentation (e.g. "🏃‍♀️" not "🏃") for consistency. Not exhaustive —
    /// the Add/Edit Habit screen also lets you type any emoji from your
    /// keyboard, so this is just a quick-pick shortlist.
    static let emojis = [
        defaultEmoji,
        // Fitness & movement
        "🏃‍♀️", "🚶‍♀️", "🏋️‍♀️", "🤸‍♀️", "🚴‍♀️", "🧘‍♀️", "🏊‍♀️", "⛹️‍♀️",
        // Mindfulness & rest
        "😴", "🙏", "🧠", "❤️", "🌙", "☀️", "🕯️", "🌿",
        // Food & health
        "🥗", "💧", "🍎", "🥦", "💊", "🦷", "🧴", "🍽️",
        // Work & focus
        "📚", "✍️", "💻", "🎯", "📵", "🕰️", "🗓️", "💼",
        // Home & chores
        "🧹", "🧺", "🪴", "🐾", "👩‍🍳", "👩‍💻", "🚭",
        // Hobbies & creativity
        "🎨", "🎸", "📖", "🎧", "🧵", "📷",
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
