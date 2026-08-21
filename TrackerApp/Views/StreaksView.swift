//
//  StreaksView.swift
//  TrackerApp
//
//  Weekly overview grid: one row per habit, one dot per day (Mon–Sun),
//  filled in the habit's own color when completed that day.
//

import SwiftUI

struct StreaksView: View {
    @ObservedObject var store: HabitStore

    private let calendar = Calendar.habitCalendar
    private var today: Date { calendar.startOfDay(for: Date()) }
    private var weekDays: [Date] {
        let weekStart = calendar.startOfWeek(containing: today)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private static let letterFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEEE" // single-letter weekday
        return f
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if store.habits.isEmpty {
                        Text("Add some habits to see your week here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
                            .frame(maxWidth: .infinity)
                    } else {
                        weekGrid
                    }
                }
                .padding()
            }
            .navigationTitle("Streaks")
        }
    }

    private var weekGrid: some View {
        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 14) {
            GridRow {
                Text("")
                    .frame(minWidth: 110, alignment: .leading)
                ForEach(weekDays, id: \.self) { day in
                    weekdayHeader(day)
                }
            }

            ForEach(store.orderedHabits) { habit in
                let streak = store.streak(for: habit)
                GridRow {
                    HStack(spacing: 6) {
                        Text(habit.emoji)
                        Text(habit.name)
                            .font(.subheadline)
                            .lineLimit(1)

                        if streak > 0 {
                            HStack(spacing: 2) {
                                Text("🔥")
                                Text("\(streak)")
                            }
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        }
                    }
                    .frame(minWidth: 110, alignment: .leading)

                    ForEach(weekDays, id: \.self) { day in
                        dot(for: habit, on: day)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func weekdayHeader(_ day: Date) -> some View {
        let isToday = calendar.isDate(day, inSameDayAs: today)
        Text(Self.letterFormatter.string(from: day))
            .font(.caption.weight(.semibold))
            .frame(width: 28, height: 28)
            .background(
                Circle().fill(isToday ? Color.red.opacity(0.85) : Color.secondary.opacity(0.12))
            )
            .foregroundStyle(isToday ? .white : .secondary)
    }

    @ViewBuilder
    private func dot(for habit: Habit, on day: Date) -> some View {
        let isFuture = day > today
        let isCompleted = store.isCompleted(habit, on: day)

        Circle()
            .fill(isCompleted ? Color(hex: habit.color) : Color.secondary.opacity(0.15))
            .frame(width: 22, height: 22)
            .opacity(isFuture ? 0.4 : 1)
    }
}

#Preview {
    StreaksView(store: HabitStore())
}
