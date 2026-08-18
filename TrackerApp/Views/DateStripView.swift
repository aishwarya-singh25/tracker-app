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

    var body: some View {
        HStack(spacing: 8) {
            ForEach(weekDays, id: \.self) { day in
                let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
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
                            .foregroundStyle(isSelected ? .white : .primary)
                    }
                }
                .disabled(isFuture)
                .opacity(isFuture ? 0.3 : 1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DateStripView(selectedDate: .constant(Date()))
        .padding()
}
