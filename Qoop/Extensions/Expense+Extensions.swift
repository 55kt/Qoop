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
        guard quantity >= 0 else { return 0 }
        return amount * Double(quantity)
    }
    
    static func exists(context: NSManagedObjectContext, title: String, budget: Budget) -> Bool {
        let request = Expense.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@ AND budget == %@", title, budget)
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("❌ Error checking expense existence: \(error.localizedDescription)")
            return false
        }
    }
}
