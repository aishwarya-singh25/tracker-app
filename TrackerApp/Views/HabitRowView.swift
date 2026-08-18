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

    var body: some View {
        HStack(spacing: 12) {
            Text(habit.emoji)
                .font(.title2)

            Text(habit.name)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()

            if streak > 0 {
                HStack(spacing: 3) {
                    Text("🔥")
                    Text("\(streak)")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            }

            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(.white, isCompleted ? .white.opacity(0.25) : .clear)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(hex: habit.color), in: RoundedRectangle(cornerRadius: 16))
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
