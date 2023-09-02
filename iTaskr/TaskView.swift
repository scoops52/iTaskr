//
//  TaskView.swift
//  iTaskr
//
//  Created by Sean Cooper on 8/31/23.
//
import Foundation
import SwiftUI

struct TaskView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var task: Task
    @State private var timer: Timer? = nil
    @State private var isTimerRunning = false
    @State private var finishHour: Int = 0
    @State private var finishMinute: Int = 0
    @State private var finishTime = "--:--"
    
    
    
    private func toggleTimer() {
        if isTimerRunning {
            timer?.invalidate()
            timer = nil
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { time in
                if task.timeRemaining > 0 {
                    task.timeRemaining -= 1
                    estimateFinishTime()
                    try? moc.save()
                }
            }
        }
        isTimerRunning.toggle()
    }
    
    var trimValue: Double {
        if task.duration > 0 {
            return Double(task.timeRemaining) / Double(task.duration)
        } else {
            return 0.0
        }
    }
    
    
    
    
    var formattedTime: String {
        let hours = task.timeRemaining / 3600
        let minutes = (task.timeRemaining % 3600) / 60
        let seconds = task.timeRemaining % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func estimateFinishTime() {
        let start = Date.now
        let finish = start.addingTimeInterval(Double(task.timeRemaining))
        finishTime = finish.formatted(date: .omitted, time: .shortened)
        
    }
    
    func deleteTask() {
        moc.delete(task)
        try? moc.save()
        presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .stroke(Color.orange.opacity(0.5), lineWidth: 10)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(trimValue) )
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(270))
                        .animation(.linear(duration: 1.0), value: trimValue)
                    VStack(spacing: 5) {
                        Text(formattedTime)
                            .font(.largeTitle)
                        HStack {
                            Image(systemName: "checkmark.circle.fill" )
                            
                            Text(finishTime)
                        }
                        .foregroundColor(isTimerRunning ? .primary : .secondary)
                    }
                }
                .frame(width: 300, height: 300)
                
                Button {
                    toggleTimer()
                } label: {
                    Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(isTimerRunning ? Color.orange : Color.green)
                        .background(isTimerRunning ? Color.orange.opacity(0.3) : Color.green.opacity(0.3))
                        .clipShape(Circle())
                    
                }
                
                Button("Delete Task", role: .destructive) {
                    deleteTask()
                }
                .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                        
                
                
                .navigationTitle(task.name ?? "No Task")
            }
        }
    }
    
}
