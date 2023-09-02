//
//  AddTaskView.swift
//  iTaskr
//
//  Created by Sean Cooper on 8/30/23.
//
import CoreData
import SwiftUI

class TimerViewModel: ObservableObject {
    @Published var selectedHoursAmount = 10
    @Published var selectedMinutesAmount = 10
    
    let hoursRange = 0...23
        let minutesRange = 0...59
}

struct AddTaskView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: []) private var tasks: FetchedResults<Task>

    @StateObject private var model = TimerViewModel()
    
    @State private var name = ""
    @State private var durationHours = 1
    @State private var durationMinutes = 0
    
    let taskCount: Int
    
    let hoursRange = 0...8
    let minutesRange = 0...59
    
    private func saveTask() {
        let setTime = Int16((durationHours * 3600) + (durationMinutes * 60))
        let newTask = Task(context: moc)
        newTask.id = UUID()
        newTask.name = name
        newTask.duration = setTime
        newTask.timeRemaining = setTime
        newTask.displayPriority = (tasks.last?.displayPriority ?? 0) + 1
        try? moc.save()
    }
    
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
                Button(action: {
                    saveTask()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName:"plus.circle.fill")
                        Text("Add Task")
                    }
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
