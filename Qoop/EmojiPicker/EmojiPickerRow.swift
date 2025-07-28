//
//  EmojiPicker.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import SwiftUI

struct EmojiPickerRow: View {
    // MARK: - Properties
    @State private var showEmojiView = false
    var title: String
    @Binding var selection: String
    
    // MARK: - Body
    var body: some View {
        Button {
            showEmojiView.toggle()
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(.accent)
                Spacer()
                Text(selection)
                    .font(.system(size: 40))
            }// Hstack
            .padding(.horizontal)
            .tint(.primary)
            .font(.headline)
            .frame(width: 300, height: 55)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        }// Button
        .sheet(isPresented: $showEmojiView) {
            EmojiPickerView(selectedEmoji: $selection)
        }// sheet
    }// body
}// View

// MARK: - Preview
#Preview {
    EmojiPickerRow(title: "Select an icon", selection: .constant(""))
}
