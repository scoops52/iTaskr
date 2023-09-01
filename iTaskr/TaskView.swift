//
//  TaskView.swift
//  iTaskr
//
//  Created by Sean Cooper on 8/31/23.
//

import SwiftUI

struct TaskView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var task: Task
    @State private var timer: Timer? = nil
    @State private var isTimerRunning = false
    @State private var timeRemaining: Int
    let totalTime: Int
        
        init(task: Task) {
            self.task = task
            // Initialize timeRemaining with the value of task.timeRemaining
            self.timeRemaining = Int(task.timeRemaining)
            self.totalTime = Int(task.duration)
        }

    private func toggleTimer() {
        if isTimerRunning {
            timer?.invalidate()
            timer = nil
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { time in
                if task.timeRemaining > 0 {
                    task.timeRemaining -= 1
                    timeRemaining -= 1
                    try? moc.save()
                }
            }
        }
        isTimerRunning.toggle()
    }
    


    
    var formattedTime: String {
        let hours = timeRemaining / 3600
        let minutes = (timeRemaining % 3600) / 60
        let seconds = timeRemaining % 60
        
        if hours > 0 {
                    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                } else {
                    return String(format: "%02d:%02d", minutes, seconds)
                }
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Circle()
                        .stroke(Color.orange.opacity(0.5), lineWidth: 10)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(timeRemaining / totalTime) )
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(270))
                    //                    .animation(.linear(duration: 1.0), value: timeRemaining / totalTime)
                    Text(formattedTime)
                }
                Button("Start") {
                    toggleTimer()
                }
            }
            .frame(width: 300, height: 300)
            .navigationTitle(task.name ?? "No Task")
        }
    }
}

