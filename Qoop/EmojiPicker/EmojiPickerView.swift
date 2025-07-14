//
//  EmojiPickerView.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import SwiftUI

struct EmojiPickerView: View {
    @ObservedObject private var vm = EmojiDataModel()
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                    ForEach(vm.emojiFilter, id: \.self) { iconKey in
                        Text(vm.emoji[iconKey] ?? "❓")
                            .font(.title)
                            .padding(10)
                            .frame(width: 60, height: 60)
                            .background(.ultraThinMaterial, in: Circle())
                            .onTapGesture {
                                selectedEmoji = vm.emoji[iconKey] ?? ""
                                dismiss()
                            }
                    }
                }
                .searchable(text: $vm.searchText)
            }
            .navigationTitle("Emojis")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal, 8)
        }
    }
}

#Preview {
    EmojiPickerView(selectedEmoji: .constant(""))
}
