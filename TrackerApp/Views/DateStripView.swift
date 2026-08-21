//
//  DateStripView.swift
//  TrackerApp
//
//  A 7-day (Mon–Sun) strip for navigating between days on the Today screen.
//  Swiping left/right pages between weeks (unlimited, both directions) via
//  a 3-page recentering TabView — the standard "infinite paging" trick.
//

import SwiftUI

struct DateStripView: View {
    @Binding var selectedDate: Date

    /// Weeks away from the week containing `Date()`. Unbounded — no clamping,
    /// so navigation is unlimited in both directions.
    @State private var weekOffset: Int
    /// Always resets to 1 after a swipe settles; indexes
    /// `[weekOffset-1, weekOffset, weekOffset+1]`.
    @State private var pageSelection: Int = 1

    private let calendar = Calendar.habitCalendar
    private var today: Date { calendar.startOfDay(for: Date()) }

    private static let letterFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEEE" // single-letter weekday
        return f
    }()

    init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate
        let cal = Calendar.habitCalendar
        let todayWeekStart = cal.startOfWeek(containing: Date())
        let selectedWeekStart = cal.startOfWeek(containing: selectedDate.wrappedValue)
        let offset = cal.dateComponents([.weekOfYear], from: todayWeekStart, to: selectedWeekStart).weekOfYear ?? 0
        _weekOffset = State(initialValue: offset)
    }

    private func weekDays(forOffset offset: Int) -> [Date] {
        let todayWeekStart = calendar.startOfWeek(containing: Date())
        guard let weekStart = calendar.date(byAdding: .weekOfYear, value: offset, to: todayWeekStart) else {
            return []
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    var body: some View {
        TabView(selection: $pageSelection) {
            weekPage(offset: weekOffset - 1).tag(0)
            weekPage(offset: weekOffset).tag(1)
            weekPage(offset: weekOffset + 1).tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 64)
        .onChange(of: pageSelection) { _, newValue in
            guard newValue != 1 else { return }
            let delta = newValue - 1 // -1 or +1
            weekOffset += delta
            if let shifted = calendar.date(byAdding: .weekOfYear, value: delta, to: selectedDate) {
                selectedDate = shifted
            }
            pageSelection = 1
        }
    }

    private func weekPage(offset: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(weekDays(forOffset: offset), id: \.self) { day in
                dayButton(for: day)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func dayButton(for day: Date) -> some View {
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

#Preview {
    DateStripView(selectedDate: .constant(Date()))
        .padding()
}
