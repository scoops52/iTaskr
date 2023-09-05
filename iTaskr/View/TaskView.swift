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
    
    
    
    @Environment(\.scenePhase) var phase
    @State var lastActiveTimeStamp: Date = Date()
    
    var timeRemaining: Int16 {
        return task.duration - task.elapsedTime
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
            VStack(spacing: 40) {
                Text(task.name ?? "Task")
                    .font(.largeTitle)
                    
                    .foregroundColor(.teal)
//                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 15)
                    
                    Circle()
                        .trim(from: 0, to: timerModel.progress )
                        .stroke(AngularGradient(colors: [Color.cyan, Color.indigo, Color.purple, Color.cyan], center: .center), style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
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
                    Image(systemName: timerModel.isStarted ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(timerModel.isStarted ? Color.gray : Color.indigo)
                        .background(timerModel.isStarted ? Color.gray.opacity(0.3) : Color.indigo.opacity(0.3))
                        .clipShape(Circle())
                    
                }
//                Spacer()
                    
                    Button("Reset Task") {
                        timerModel.isFinished = false
                        task.timeRemaining = task.duration
                        timerModel.initTimer(taskDuration: task.duration, taskTimeRemaining: task.timeRemaining)
                        
                        try? moc.save()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .foregroundColor(.cyan)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    
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
                        if newValue == .background {
                            lastActiveTimeStamp = Date()
                            timerModel.addNotification()
                        }
                        
                        if newValue == .active{
                            let currentTimeStampDiff = Date().timeIntervalSince(lastActiveTimeStamp)
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
//            .background(Color.gray.opacity(0.3))
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

            
            
            
            
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive, action: {
                    deleteTask()
                }) {
                    Text("Delete Task")
                        .foregroundColor(Color.red)
                }
            }
        }
        
    }
}
    

