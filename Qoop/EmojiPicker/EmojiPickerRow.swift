//
//  EmojiPicker.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import SwiftUI

struct EmojiPickerRow: View {
    @State private var showEmojiView = false
    var title: String
    @Binding var selection: String
    
    
    var body: some View {
        Button {
            showEmojiView.toggle()
        } label: {
            HStack {
                Text(title)
                Spacer()
                Text(selection)
                    .font(.title)
            }
            .padding(.horizontal)
            .tint(.primary)
            .font(.headline)
            .frame(width: 300, height: 55)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        }
        .sheet(isPresented: $showEmojiView) {
            EmojiPickerView(selectedEmoji: $selection)
        }
        
    }
}

#Preview {
    EmojiPickerRow(title: "Select an icon", selection: .constant(""))
}
