//
//  IconPickerStyle.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import SwiftUI

struct IconPickerStyle: View {
    
    @State private var vm = DataModel()
    @Binding var selectedIcon: String
    @Binding var color: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 5)) {
                    ForEach(vm.iconFilter, id: \.self) { icon in
                        Image(systemName: icon)
                            .renderingMode(color ? .original : .template)
                            .font(.title)
                            .padding(10)
                            .onTapGesture {
                                selectedIcon = icon
                                dismiss()
                            }
                    }
                    .frame(width: 60, height: 60)
                    .background(.ultraThinMaterial, in: Circle())
                }
                .searchable(text: $vm.searchText)
            }
            .navigationTitle("Icons")
            .searchable(text: $vm.searchText)
            .padding(.horizontal, 8)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    color.toggle()
                } label: {
                    Image(systemName: "lightspectrum.horizontal")
                        .renderingMode(color ? .template : .original)
                        .font(.system(size: 50)).bold()
                        .background(.black, in: Circle())
                }
                .tint(.primary)

            }
        }
    }
}
