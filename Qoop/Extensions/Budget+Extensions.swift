//
//  Budget+Extensions.swift
//  Qoop
//
//  Created by Vlad on 13/7/25.
//

import Foundation
import CoreData

extension Budget {
    
    static func exists(context: NSManagedObjectContext, title: String) -> Bool {
        let request = NSFetchRequest<Budget>(entityName: "Budget")
        request.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("❌ Error checking budget existence: \(error.localizedDescription)")
            return false
        }
    }
}
