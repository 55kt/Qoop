//
//  CV.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import SwiftUI

struct CV: View {
    @State private var icon = ""
    
    var body: some View {
        IconPicker(title: "Select an icon", selection: $icon)
    }
}

#Preview {
    CV()
}
