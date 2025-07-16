//
//  Expense+Extensions.swift
//  Qoop
//
//  Created by Vlad on 15/7/25.
//

import Foundation
import CoreData

extension Expense {
    
    public var total: Double {
        amount * Double(quantity)
    }
    
    static func exists(context: NSManagedObjectContext, title: String, budget: Budget) -> Bool {
        let request = Expense.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@ AND budget == %@", title, budget)
        do {
            let results = try context.fetch(request)
            return !results.isEmpty
        } catch {
            return false
        }
    }
}
