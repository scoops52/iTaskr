//
//  iTaskrApp.swift
//  iTaskr
//
//  Created by Sean Cooper on 8/30/23.
//

import SwiftUI

@main
struct iTaskrApp: App {
    @StateObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
