//
//  TimerModel.swift
//  iTaskr
//
//  Created by Sean Cooper on 9/3/23.
//

import SwiftUI

class TimerModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var progress: CGFloat = 1
    @Published var timerStringValue: String = "00:00"
    @Published var isStarted: Bool = false
    @Published var isFinished: Bool = false
    
    @Published var totalSeconds: Int = 100
    @Published var staticTotalSeconds: Int = 100
    
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    
    
    override init() {
        super.init()
        self.authorizeNotification()
    }
    
    // Initiate Timer
    func initTimer(taskDuration: Int16, taskTimeRemaining: Int16){
        totalSeconds = Int(taskTimeRemaining)
        staticTotalSeconds = Int(taskDuration)
        progress = CGFloat(totalSeconds) / CGFloat(staticTotalSeconds)
        // Create time display
       hours = totalSeconds / 3600
        minutes = (totalSeconds % 3600) / 60
        seconds = totalSeconds % 60
        timerStringValue = hours > 0 ? String(format: "%02d:%02d:%02d", hours, minutes, seconds) : String(format: "%02d:%02d", minutes, seconds)
    }
    
    //Starting timer:
    func startTimer(){
        withAnimation(.easeInOut(duration: 0.25)){
            if totalSeconds > 0 {
                isStarted = true
            }}
        // Create time display
        hours = totalSeconds / 3600
        minutes = (totalSeconds % 3600) / 60
        seconds = totalSeconds % 60
        timerStringValue = hours > 0 ? String(format: "%02d:%02d:%02d", hours, minutes, seconds) : String(format: "%02d:%02d", minutes, seconds)
        
        
        print("timer started")
    }
    
    //Stopping timer:
    func stopTimer(){
        withAnimation {
            isStarted = false
            print("timer stopped")
        }
    }
    
    //updating timer:
    func updateTimer(){
        totalSeconds -= 1
        // timer trim progress
        progress = CGFloat(totalSeconds) / CGFloat(staticTotalSeconds)
        progress = (progress < 0 ? 0 : progress)
        hours = totalSeconds / 3600
        minutes = (totalSeconds % 3600) / 60
        seconds = totalSeconds % 60
        timerStringValue = hours > 0 ?  String(format: "%02d:%02d:%02d", hours, minutes, seconds) : String(format: "%02d:%02d", minutes, seconds)
        if totalSeconds <= 0 {
            isStarted = false
            isFinished = true
            timerStringValue = "00:00"
            progress = 0
            print("Finished")
        }
    }
    // notification
    func authorizeNotification(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { _, _ in }
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner])
    }

    func addNotification() {
        let content = UNMutableNotificationContent()
        content.title = "iTaskr"
        content.subtitle = "Task finished! Great Job!"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(totalSeconds), repeats: false))
        
        UNUserNotificationCenter.current().add(request)
    }
}


