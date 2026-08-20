//
//  DateStripView.swift
//  TrackerApp
//
//  A 7-day (Mon–Sun) strip for navigating between days on the Today screen.
//

import SwiftUI

struct DateStripView: View {
    @Binding var selectedDate: Date

    private let calendar = Calendar.habitCalendar
    private var today: Date { calendar.startOfDay(for: Date()) }
    private var weekDays: [Date] {
        let weekStart = calendar.startOfWeek(containing: selectedDate)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private static let letterFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEEE" // single-letter weekday
        return f
    }()

    /// True when the displayed week is the one containing today — used to
    /// stop paging forward into weeks that haven't happened yet.
    private var isCurrentWeek: Bool {
        calendar.isDate(
            calendar.startOfWeek(containing: selectedDate),
            inSameDayAs: calendar.startOfWeek(containing: today)
        )
    }

    var body: some View {
        HStack(spacing: 4) {
            Button {
                shiftWeek(by: -7)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 32)
            }

            HStack(spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                    let isToday = calendar.isDate(day, inSameDayAs: today)
                    let isFuture = day > today

                    Button {
                        selectedDate = day
                    } label: {
                        VStack(spacing: 4) {
                            Text(Self.letterFormatter.string(from: day))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(calendar.component(.day, from: day))")
                                .font(.subheadline.weight(isSelected ? .bold : .regular))
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle().fill(isSelected ? Color.accentColor : Color.clear)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.accentColor, lineWidth: 1.5)
                                        .opacity(isToday && !isSelected ? 1 : 0)
                                )
                                .foregroundStyle(isSelected ? .white : .primary)
                        }
                    }
                    .disabled(isFuture)
                    .opacity(isFuture ? 0.3 : 1)
                }
            }
            .frame(maxWidth: .infinity)

            Button {
                shiftWeek(by: 7)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isCurrentWeek ? .quaternary : .secondary)
                    .frame(width: 24, height: 32)
            }
            .disabled(isCurrentWeek)
        }
    }

    private func shiftWeek(by days: Int) {
        guard let shifted = calendar.date(byAdding: .day, value: days, to: selectedDate) else { return }
        selectedDate = min(shifted, today)
    }
}

#Preview {
    DateStripView(selectedDate: .constant(Date()))
        .padding()
}
