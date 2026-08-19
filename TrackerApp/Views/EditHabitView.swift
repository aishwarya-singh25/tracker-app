//
//  EditHabitView.swift
//  TrackerApp
//
//  Sheet for editing an existing habit's name/icon/color (opened from
//  Today screen's Edit mode).
//

import SwiftUI

struct EditHabitView: View {
    let habit: Habit
    let onSave: (String, String, String, TimeBlock) -> Void // name, emoji, color, timeBlock

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var selectedEmoji: String
    @State private var selectedColor: String
    @State private var selectedTimeBlock: TimeBlock
    @State private var customEmojiInput = ""

    private let emojiColumns = Array(repeating: GridItem(.flexible()), count: 6)

    init(habit: Habit, onSave: @escaping (String, String, String, TimeBlock) -> Void) {
        self.habit = habit
        self.onSave = onSave
        _name = State(initialValue: habit.name)
        _selectedEmoji = State(initialValue: habit.emoji)
        _selectedColor = State(initialValue: habit.color)
        _selectedTimeBlock = State(initialValue: habit.timeBlock)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Read a book", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: emojiColumns, spacing: 12) {
                        ForEach(HabitPresets.emojis, id: \.self) { emoji in
                            Text(emoji)
                                .font(.title2)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle().fill(selectedEmoji == emoji ? Color.accentColor.opacity(0.2) : .clear)
                                )
                                .onTapGesture { selectedEmoji = emoji }
                        }
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Text("Or type any emoji")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("🙂", text: $customEmojiInput)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .onChange(of: customEmojiInput) { _, newValue in
                                if let lastCharacter = newValue.last {
                                    selectedEmoji = String(lastCharacter)
                                }
                                customEmojiInput = ""
                            }
                    }
                }

                Section("Time of Day") {
                    Picker("Time of Day", selection: $selectedTimeBlock) {
                        ForEach(TimeBlock.allCases) { block in
                            Text(block.title).tag(block)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Color") {
                    HStack {
                        ForEach(HabitPresets.colors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle().strokeBorder(.primary, lineWidth: selectedColor == hex ? 2 : 0)
                                        .padding(-3)
                                )
                                .onTapGesture { selectedColor = hex }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    HabitRowView(
                        habit: Habit(
                            id: habit.id, userId: habit.userId,
                            name: name.isEmpty ? "Habit name" : name,
                            emoji: selectedEmoji, color: selectedColor, timeBlock: selectedTimeBlock,
                            sortOrder: habit.sortOrder, archivedAt: habit.archivedAt, createdAt: habit.createdAt
                        ),
                        isCompleted: false,
                        streak: 0,
                        onToggle: {}
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 4)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let emoji = selectedEmoji.isEmpty ? HabitPresets.defaultEmoji : selectedEmoji
                        onSave(name.trimmingCharacters(in: .whitespacesAndNewlines), emoji, selectedColor, selectedTimeBlock)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditHabitView(
        habit: Habit(
            id: UUID(), userId: UUID(), name: "Workout", emoji: "💪",
            color: "#4C6FFF", timeBlock: .morning, sortOrder: 0,
            archivedAt: nil, createdAt: Date()
        ),
        onSave: { _, _, _, _ in }
    )
}
