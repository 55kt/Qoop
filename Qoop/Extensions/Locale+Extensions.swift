//
//  Locale+Extensions.swift
//  Qoop
//
//  Created by Vlad on 15/7/25.
//

import Foundation

extension Locale {
    static var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
}
