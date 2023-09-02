//
//  AddTaskView.swift
//  iTaskr
//
//  Created by Sean Cooper on 8/30/23.
//

import SwiftUI

class TimerViewModel: ObservableObject {
    @Published var selectedHoursAmount = 10
    @Published var selectedMinutesAmount = 10
    
    let hoursRange = 0...23
        let minutesRange = 0...59
}

struct AddTaskView: View {
    @Environment(\.managedObjectContext) var moc
    @StateObject private var model = TimerViewModel()
    
    @State private var name = ""
    @State private var durationHours = 1
    @State private var durationMinutes = 0
    
    let taskCount: Int
    
    let hoursRange = 0...8
    let minutesRange = 0...59
    
    var body: some View {
        
        Form {
            Section {
                Text("Task Name")
                    .font(.headline)
                
                TextField("Name", text: $name)
            }
            
            Section {
               Text("Task Duration")
                    .font(.headline)
                
                HStack {
                    Picker("Hours", selection: $durationHours) {
                        ForEach(hoursRange, id: \.self) { hour in
                            Text("\(hour)")
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Text("Hours")
                    
                    Picker("Minutes", selection: $durationMinutes) {
                        ForEach(minutesRange, id: \.self) { minute in
                            Text("\(minute)")
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Text("Minutes")
                }
            }
            
            Section {
                Button("Save") {
                    let setTime = Int16((durationHours * 3600) + (durationMinutes * 60))
                    let newTask = Task(context: moc)
                    newTask.id = UUID()
                    newTask.name = name
                    newTask.duration = setTime
                    newTask.timeRemaining = setTime
                    newTask.displayPriority = Int16(taskCount)
                    try? moc.save()
                }
            }
            
            
            
        }
        
        
    }
}
    


struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(taskCount: 5)
    }
}
