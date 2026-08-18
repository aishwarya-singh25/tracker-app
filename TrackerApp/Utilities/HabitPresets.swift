//
//  HabitPresets.swift
//  TrackerApp
//
//  Curated pickers for the Add/Edit Habit screen — keeps habit styling
//  simple (per plan.md) instead of a full custom color/emoji picker.
//

import Foundation

enum HabitPresets {
    /// Curated icon set for habits. Any human/person glyph uses the female
    /// presentation (e.g. "🏃‍♀️" not "🏃") for consistency.
    static let emojis = [
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

    /// The emoji assigned when a habit has none selected.
    static let defaultEmoji = emojis[0]

    /// Hex strings, chosen to read clearly as both a background fill and text-legible.
    static let colors = [
        "#4C6FFF", // blue
        "#34C77B", // green
        "#FF7A59", // coral
        "#A8763E", // brown
        "#8A6DFF", // purple
        "#F2555A", // red
        "#3FC0C0", // teal
        "#5B8DEF", // periwinkle
    ]
}
