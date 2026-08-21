//
//  HabitRowView.swift
//  TrackerApp
//

import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let isCompleted: Bool
    let streak: Int
    let onToggle: () -> Void

    /// A dark, warm neutral that stays readable on every pastel row color —
    /// deliberately not `.primary`, which would flip to white in dark mode
    /// against these fixed-light backgrounds.
    private static let textColor = Color(hex: "#2E2A24")

    private var rowColor: Color { Color(hex: HabitPresets.displayColor(for: habit.color)) }

    var body: some View {
        HStack(spacing: 9) {
            Text(habit.emoji)
                .font(.body)

            Text(habit.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Self.textColor)
                .lineLimit(1)

            Spacer()

            if streak > 0 {
                HStack(spacing: 2) {
                    Text("🔥")
                    Text("\(streak)")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Self.textColor.opacity(0.6))
            }

            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isCompleted ? Self.textColor : Self.textColor.opacity(0.35))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(rowColor, in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    HabitRowView(
        habit: Habit(
            id: UUID(), userId: UUID(), name: "Workout", emoji: "💪",
            color: "#4C6FFF", timeBlock: .morning, sortOrder: 0,
            archivedAt: nil, createdAt: Date()
        ),
        isCompleted: true,
        streak: 9,
        onToggle: {}
    )
    .padding()
}
