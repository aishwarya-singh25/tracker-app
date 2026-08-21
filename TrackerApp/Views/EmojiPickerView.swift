//
//  EmojiPickerView.swift
//  TrackerApp
//
//  Shared emoji picker used by Add/Edit Habit: a "none" chip, a few
//  suggested emoji shortcuts, and a free-entry field for anything else.
//

import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String

    var body: some View {
        HStack(spacing: 12) {
            // "None" chip
            Button {
                selectedEmoji = ""
            } label: {
                Image(systemName: "slash.circle")
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle().fill(selectedEmoji.isEmpty ? Color.accentColor.opacity(0.2) : .clear)
                    )
            }
            .buttonStyle(.plain)

            ForEach(HabitPresets.suggestedEmojis, id: \.self) { emoji in
                Text(emoji)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle().fill(selectedEmoji == emoji ? Color.accentColor.opacity(0.2) : .clear)
                    )
                    .onTapGesture { selectedEmoji = emoji }
            }

            Spacer()

            TextField("✏️", text: $selectedEmoji)
                .font(.title2)
                .multilineTextAlignment(.center)
                .frame(width: 44, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary.opacity(0.3))
                )
                .onChange(of: selectedEmoji) { _, newValue in
                    if let last = newValue.last {
                        selectedEmoji = String(last)
                    }
                }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EmojiPickerView(selectedEmoji: .constant("🏃‍♀️"))
        .padding()
}
