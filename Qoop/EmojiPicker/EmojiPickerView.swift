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
        if searchText.isEmpty {
            return emojiCategories[selectedCategoryIndex].emojis
        } else {
            return emojiCategories.flatMap { $0.emojis }.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) || $0.symbol.contains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(emojiCategories.indices, id: \.self) { index in
                            let category = emojiCategories[index]
                            Text(category.name)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedCategoryIndex == index ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(10)
                                .onTapGesture {
                                    selectedCategoryIndex = index
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(filteredEmojis) { emoji in
                            Text(emoji.symbol)
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(.ultraThinMaterial, in: Circle())
                                .onTapGesture {
                                    selectedEmoji = emoji.symbol
                                    dismiss()
                                }
                                .transition(.scale)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Emojis")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search Emojis")
        }
    }
}

#Preview {
    EmojiPickerView(selectedEmoji: .constant(""))
}
