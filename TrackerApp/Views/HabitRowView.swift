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

    /// Card backgrounds are pastel now, so text/icons use a fixed dark tone
    /// (not `.primary`, which would flip to white in dark mode) to stay
    /// legible against them regardless of system appearance.
    private let textColor = Color.black.opacity(0.78)

    var body: some View {
        HStack(spacing: 12) {
            Text(habit.emoji)
                .font(.title2)

            Text(habit.name)
                .font(.headline)
                .foregroundStyle(textColor)
                .lineLimit(1)

            Spacer()

            if streak > 0 {
                HStack(spacing: 3) {
                    Text("🔥")
                    Text("\(streak)")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(textColor)
            }

            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(textColor, isCompleted ? Color.black.opacity(0.12) : .clear)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(hex: habit.color), Color(hex: habit.color).opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
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
