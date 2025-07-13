//
//  IconPicker.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import SwiftUI

struct IconPicker: View {
    @State private var showIconView = false
    @State private var colors = false
    var title: String
    @Binding var selection: String
    
    
    var body: some View {
        Button {
            showIconView.toggle()
        } label: {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: selection)
                    .renderingMode(colors ? .original : .template)
                    .font(.title)
            }
            .padding(.horizontal)
            .tint(.primary)
            .font(.headline)
            .frame(width: 300, height: 55)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        }
        .sheet(isPresented: $showIconView) {
            IconPickerStyle(selectedIcon: $selection, color: $colors)
        }

    }
}
