//
//  EmojiPickerView.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategoryIndex = 0
    @State private var searchText = ""
    
    private var filteredEmojis: [Emoji] {
        let emojis: [Emoji]
        if searchText.isEmpty {
            emojis = emojiCategories[selectedCategoryIndex].emojis
        } else {
            emojis = emojiCategories.flatMap { $0.emojis }.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        return emojis.filter { !$0.symbol.isEmpty && !$0.symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }// filtered emoji
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                emojiGrid
            }// VStack
            .navigationTitle("Emojis")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }// toolbar
            
            if searchText.isEmpty {
                categorySection
            }// if
        }// NavigationStack
    }// body
    
    // MARK: - Category Section
    private var categorySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(emojiCategories.indices, id: \.self) { index in
                    CategoryButton(
                        title: emojiCategories[index].name,
                        isSelected: selectedCategoryIndex == index,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategoryIndex = index
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 12)
    }
    
    // MARK: - Emoji Grid
    private var emojiGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 5),
                spacing: 4
            ) {
                ForEach(Array(filteredEmojis.enumerated()), id: \.offset) { index, emoji in
                    EmojiCell(
                        emoji: emoji.symbol,
                        onTap: {
                            selectedEmoji = emoji.symbol
                            dismiss()
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .animation(nil, value: selectedCategoryIndex)
        }
    }
}

// MARK: - Optimized Components

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? Color.accentColor : Color.clear,
                    in: Capsule()
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmojiCell: View {
    let emoji: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(emoji)
                .font(.system(size: 40))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(PlainButtonStyle())
    }
}// EmojiCell

// MARK: - Preview
#Preview {
    EmojiPickerView(selectedEmoji: .constant(""))
}
