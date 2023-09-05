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
    @StateObject var timerModel: TimerModel = .init()
    @Environment(\.scenePhase) var phase
    @State var lastActiveTimeStamp: Date = Date()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(timerModel)
        }
       
    }
}
