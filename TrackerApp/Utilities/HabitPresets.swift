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

    /// Quick-pick emojis shown as shortcuts atop the emoji picker.
    static let suggestedEmojis = ["🏃‍♀️", "📚", "💧"]

    /// Hex strings — happy, medium-light pastels. Dark text sits on top of
    /// these directly (see `HabitRowView`/`StreaksView`), so they're kept
    /// out of "washed out" territory rather than true pale pastel.
    static let colors = [
        "#9BC6E8", // sky blue
        "#A8D6A0", // sage green
        "#F4A98D", // coral
        "#F5D577", // butter yellow
        "#C3B2E8", // lavender
        "#F3AEBB", // pink
        "#8FD9CE", // teal
        "#AAB9F0", // periwinkle
    ]

    /// Maps the old, more saturated palette (habits created before the
    /// pastel redesign) onto its pastel replacement, so existing habits pick
    /// up the new look without a data migration. Any hex not in this map
    /// (i.e. already a current preset, or a future custom value) passes
    /// through unchanged.
    private static let legacyColorMap: [String: String] = [
        "#4C6FFF": "#9BC6E8", // blue -> sky blue
        "#34C77B": "#A8D6A0", // green -> sage
        "#FF7A59": "#F4A98D", // coral -> coral
        "#A8763E": "#F5D577", // brown -> butter yellow
        "#8A6DFF": "#C3B2E8", // purple -> lavender
        "#F2555A": "#F3AEBB", // red -> pink
        "#3FC0C0": "#8FD9CE", // teal -> teal
        "#5B8DEF": "#AAB9F0", // periwinkle -> periwinkle
    ]

    /// The color to actually render for a stored habit color, translating
    /// legacy hex values to their pastel equivalent.
    static func displayColor(for hex: String) -> String {
        legacyColorMap[hex.uppercased()] ?? hex
    }
}
