//
//  String+Extensions.swift
//  Qoop
//
//  Created by Vlad on 12/7/25.
//

import Foundation

extension String {
    var isEmptyOrWhitespace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
