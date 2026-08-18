//
//  TodayView.swift
//  TrackerApp
//
//  The home screen: a date strip up top, and the day split into
//  Morning / Afternoon / Evening / Night sections below.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var auth: AuthManager
    @StateObject private var store = HabitStore()

    @State private var selectedDate = Date()
    @State private var addingHabitToBlock: TimeBlock?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    DateStripView(selectedDate: $selectedDate)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }

                    ForEach(TimeBlock.allCases) { block in
                        timeBlockSection(block)
                    }
                }
                .padding(.bottom, 24)
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") { Task { await auth.signOut() } }
                        .font(.footnote)
                }
            }
            .refreshable { await loadData() }
            .task { await loadData() }
            .sheet(item: $addingHabitToBlock) { block in
                AddHabitView(timeBlock: block) { name, emoji, color in
                    guard let userId = auth.userId else { return }
                    Task {
                        await store.addHabit(name: name, emoji: emoji, color: color, timeBlock: block, userId: userId)
                    }
                }
            }
        }
    }

    private var navigationTitle: String {
        Calendar.habitCalendar.isDateInToday(selectedDate) ? "Today" : DayKey.string(from: selectedDate)
    }

    @ViewBuilder
    private func timeBlockSection(_ block: TimeBlock) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(block.title)
                    .font(.title3.bold())
                Spacer()
                Button {
                    addingHabitToBlock = block
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }

            let habitsInBlock = store.habits(in: block)
            if habitsInBlock.isEmpty {
                Text("No habits yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
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
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func loadData() async {
        guard let userId = auth.userId else { return }
        await store.loadAll(userId: userId)
    }
}

#Preview {
    TodayView()
        .environmentObject(AuthManager())
}
