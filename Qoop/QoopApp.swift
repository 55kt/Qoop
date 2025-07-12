//
//  QoopApp.swift
//  Qoop
//
//  Created by Vlad on 12/7/25.
//

import SwiftUI

@main
struct QoopApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
