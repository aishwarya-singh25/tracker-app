//
//  AddHabitView.swift
//  TrackerApp
//
//  Sheet for creating a new habit into a given time block.
//

import SwiftUI

struct AddHabitView: View {
    let timeBlock: TimeBlock
    let onSave: (String, String, String) -> Void // name, emoji, color

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedEmoji = HabitPresets.emojis[0]
    @State private var selectedColor = HabitPresets.colors[0]

    private let emojiColumns = Array(repeating: GridItem(.flexible()), count: 6)

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
                            id: UUID(), userId: UUID(), name: name.isEmpty ? "Habit name" : name,
                            emoji: selectedEmoji, color: selectedColor, timeBlock: timeBlock,
                            sortOrder: 0, archivedAt: nil, createdAt: Date()
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
            .navigationTitle("New \(timeBlock.title) Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(name.trimmingCharacters(in: .whitespacesAndNewlines), selectedEmoji, selectedColor)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddHabitView(timeBlock: .morning, onSave: { _, _, _ in })
}
