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
    @StateObject var task: Task
    @State private var finishHour: Int = 0
    @State private var finishMinute: Int = 0
    @State private var finishTime = "--:--"
    @EnvironmentObject var timerModel: TimerModel
    
    @State private var showingEditScreen = false
    
    @Environment(\.scenePhase) var phase
//    @State var lastActiveTimeStamp: Date = Date()
    @State var lastActiveTimeStamp: Date?
    @State var isLastActiveTimeStampInitialized = false
    
    
    
    
    
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
    
    private var taskColor: Color {
        switch task.priority {
        case 1:
            return Color.red
        case 2:
            return Color.yellow
        default:
            return Color.green
        }
    }
    
    
    
    
    var body: some View {
        
        NavigationStack {
            VStack(spacing: 40) {
                Text(task.name ?? "Task")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                //                Spacer()
                ZStack {
                    Circle()
                        .stroke(taskColor.opacity(0.3), lineWidth: 15)
                    
                    Circle()
                        .trim(from: 0, to: timerModel.progress )
                        .stroke(AngularGradient(colors: [taskColor, taskColor.opacity(0.8), taskColor.opacity(0.3), taskColor.opacity(0.8), taskColor], center: .center), style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                        .rotationEffect(.degrees(270))
                        .animation(.linear(duration: 1.0), value: timerModel.progress)
                    VStack(spacing: 5) {
                        Text("\(timerModel.timerStringValue)")
                            .font(.largeTitle)
                        HStack {
                            Image(systemName: "checkmark.circle.fill" )
                            
                            Text(finishTime)
                        }
                        .foregroundColor(timerModel.isStarted ? .primary : .secondary)
                    }
                }
                .frame(width: 300, height: 300)
                //                Spacer()
                Button {
                    if timerModel.isStarted {
                        timerModel.stopTimer()
                        
                    } else {
                        timerModel.startTimer()
                        estimateFinishTime()
                    }
                } label: {
                    Image(systemName: timerModel.isStarted ? "pause.circle" : "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(taskColor)
                        .background(timerModel.isStarted ? Color.clear : taskColor.opacity(0.3))
                        .clipShape(Circle())
                    
                }
                //                Spacer()
                
                Button {
                    timerModel.isFinished = false
                    task.timeRemaining = task.duration
                    timerModel.initTimer(taskDuration: task.duration, taskTimeRemaining: task.timeRemaining)
                    
                    try? moc.save()
                } label: {
                    Text("Reset Task")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
                //                    .frame(maxWidth: .infinity)
                //                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                //                    .background(Color.blue) // Set your desired background color
                //                    .foregroundColor(.white) // Text color
                //                    .font(.headline) // Text font
                //                    .cornerRadius(10)
                //                    .shadow(color: .gray, radius: 3, x: 1, y: 2) // Add a subtle shadow
                
                
                //                    .padding()
                //                    .background(Color.gray.opacity(0.3))
                //                    .cornerRadius(10)
                //                    .fontWeight(.light)
                
                
                Spacer()
                //                Spacer()
                    .onAppear {
                        timerModel.initTimer(taskDuration: task.duration, taskTimeRemaining: task.timeRemaining)
                        
                    }
                    .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                        if timerModel.isStarted{
                            timerModel.updateTimer()
                            task.timeRemaining = Int16(timerModel.totalSeconds)
                            
                            try? moc.save()
                        }
                        
                        
                    }
                    .onChange(of: phase) { newValue in
                        if timerModel.isStarted{
                            print(newValue)
                            if newValue == .background {
                                lastActiveTimeStamp = Date()
                                print("Time Remaining: ", task.timeRemaining)
                                isLastActiveTimeStampInitialized = true
                                timerModel.addNotification()
                            }
                            if newValue == .active && isLastActiveTimeStampInitialized {
                                let currentTimeStampDiff = Date().timeIntervalSince(lastActiveTimeStamp ?? Date())
                                isLastActiveTimeStampInitialized = false
                                UNUserNotificationCenter.current()
                                    .removeAllPendingNotificationRequests()
                                if task.timeRemaining - Int16(currentTimeStampDiff) <= 0 {
                                    timerModel.isStarted = false
                                    timerModel.totalSeconds = 0
                                    task.timeRemaining = 0
                                    timerModel.isFinished = true
                                    timerModel.progress = 0
                                    timerModel.timerStringValue = "00:00"
                                } else {
                                    timerModel.totalSeconds -= Int(currentTimeStampDiff)
                                    task.timeRemaining -= Int16(currentTimeStampDiff)
                                    
                                }
                            }
                        }
                    }
                
                
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            .cornerRadius(12)
            .alert(isPresented: $timerModel.isFinished) {
                Alert(
                    title: Text("Task Duration Complete"),
                    message: Text("Great Job!"),
                    primaryButton: .default(Text("Reset Task"), action: {
                        timerModel.isFinished = false
                        task.timeRemaining = task.duration
                        timerModel.initTimer(taskDuration: task.duration, taskTimeRemaining: task.timeRemaining)
                        
                        try? moc.save()
                    }),
                    secondaryButton: .destructive(Text("Remove Task"), action: {
                        deleteTask()
                    })
                )
            }
            .background(taskColor.opacity(0.1))
        
           
            
            
            
            
            
            
        }
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive, action: {
                    showingEditScreen = true
                }) {
                    Text("Edit Task")
                    
                }
            }
        }
    
        
        
        
        .sheet(isPresented: $showingEditScreen, onDismiss: {
            timerModel.initTimer(taskDuration: task.duration, taskTimeRemaining: task.timeRemaining)
           
        }){
            EditTaskView(task: task)
        }
        
        .navigationBarTitleDisplayMode(.inline)
    }
    
}


