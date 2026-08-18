//
//  TodayView.swift
//  TrackerApp
//
//  The home screen: a date strip up top, and the day split into
//  Morning / Afternoon / Evening / Night sections below. Habits can be
//  reordered within a block via the Edit button (native List drag handles).
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var auth: AuthManager
    @ObservedObject var store: HabitStore

    @Environment(\.editMode) private var editMode
    private var isEditing: Bool { editMode?.wrappedValue.isEditing ?? false }

    @State private var selectedDate = Date()
    @State private var addingHabitToBlock: TimeBlock?
    @State private var editingHabit: Habit?

    // Collapsed state per block, persisted across launches.
    @AppStorage("collapsed_morning") private var morningCollapsed = false
    @AppStorage("collapsed_afternoon") private var afternoonCollapsed = false
    @AppStorage("collapsed_evening") private var eveningCollapsed = false
    @AppStorage("collapsed_night") private var nightCollapsed = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(TimeBlock.allCases) { block in
                    Section {
                        timeBlockContent(block)
                    } header: {
                        timeBlockHeader(block)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .top) {
                VStack(spacing: 16) {
                    DateStripView(selectedDate: $selectedDate)

                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    progressSummary
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .refreshable { await loadData() }
            .sheet(item: $addingHabitToBlock) { block in
                AddHabitView(timeBlock: block) { name, emoji, color in
                    guard let userId = auth.userId else { return }
                    Task {
                        await store.addHabit(name: name, emoji: emoji, color: color, timeBlock: block, userId: userId)
                    }
                }
            }
            .sheet(item: $editingHabit) { habit in
                EditHabitView(habit: habit) { name, emoji, color in
                    Task {
                        await store.updateHabit(habit, name: name, emoji: emoji, color: color)
                    }
                }
            }
        }
    }

    private var navigationTitle: String {
        Calendar.habitCalendar.isDateInToday(selectedDate) ? "Today" : DisplayDate.string(from: selectedDate)
    }

    private var allHabitsToday: [Habit] {
        store.orderedHabits
    }

    @ViewBuilder
    private var progressSummary: some View {
        let habits = allHabitsToday
        if !habits.isEmpty {
            let completed = habits.filter { store.isCompleted($0, on: selectedDate) }.count
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(completed) of \(habits.count) done")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                ProgressView(value: Double(completed), total: Double(habits.count))
                    .tint(.accentColor)
            }
        }
    }

    private func isCollapsed(_ block: TimeBlock) -> Binding<Bool> {
        switch block {
        case .morning: return $morningCollapsed
        case .afternoon: return $afternoonCollapsed
        case .evening: return $eveningCollapsed
        case .night: return $nightCollapsed
        }
    }

    private func blockIcon(_ block: TimeBlock) -> String {
        switch block {
        case .morning: return "☀️"
        case .afternoon: return "🌤️"
        case .evening: return "🌆"
        case .night: return "🌙"
        }
    }

    @ViewBuilder
    private func timeBlockHeader(_ block: TimeBlock) -> some View {
        let collapsed = isCollapsed(block)

        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    collapsed.wrappedValue.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Text(blockIcon(block))
                    Text(block.title)
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Image(systemName: "chevron.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(collapsed.wrappedValue ? 180 : 0))
                }
            }
            .buttonStyle(.plain)
            .disabled(isEditing)

            Spacer()

            Button {
                addingHabitToBlock = block
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .disabled(isEditing)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .textCase(nil)
    }

    @ViewBuilder
    private func timeBlockContent(_ block: TimeBlock) -> some View {
        // While editing, keep every block expanded so drag handles are usable.
        if isEditing || !isCollapsed(block).wrappedValue {
            let habitsInBlock = store.habits(in: block)
            if habitsInBlock.isEmpty {
                Text("No habits yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 14)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal)
                    )
            } else {
                ForEach(habitsInBlock) { habit in
                    HabitRowView(
                        habit: habit,
                        isCompleted: store.isCompleted(habit, on: selectedDate),
                        streak: store.streak(for: habit)
                    ) {
                        guard let userId = auth.userId else { return }
                        Task {
                            await store.toggleCompletion(habit, on: selectedDate, userId: userId)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .swipeActions(edge: .leading) {
                        Button {
                            editingHabit = habit
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
                .onMove { source, destination in
                    guard let userId = auth.userId else { return }
                    Task {
                        await store.reorder(in: block, from: source, to: destination, userId: userId)
                    }
                }
            }
        }
    }

    private func loadData() async {
        guard let userId = auth.userId else { return }
        await store.loadAll(userId: userId)
    }
}

#Preview {
    TodayView(store: HabitStore())
        .environmentObject(AuthManager())
}
