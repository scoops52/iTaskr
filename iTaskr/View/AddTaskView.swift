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
    @State private var priority = 1
    
    @FocusState private var nameIsFocused: Bool
    
    
    
    
    
    let hoursRange = 0...8
    let minutesRange = 0...59
    
    let priorityLevels = [1, 2, 3]
    
    private func priorityString(for level: Int) -> String {
        switch level {
        case 1:
            return "High"
        case 2:
            return "Medium"
        default:
            return "Low"
        }
    }
    
    private func saveTask() {
        let setTime = Int16((durationHours * 3600) + (durationMinutes * 60))
        let newTask = Task(context: moc)
        newTask.id = UUID()
        newTask.name = name
        newTask.duration = setTime
        newTask.timeRemaining = setTime
        newTask.displayPriority = (tasks.last?.displayPriority ?? 0) + 1
        newTask.priority = Int16(priority)
        
        try? moc.save()
        print("Task duration: \(newTask.duration)")
    }
    
    var body: some View {
        
        Form {
            Section {
                Text("Task Name")
                    .font(.headline)
                
                TextField("Name", text: $name)
                    .focused($nameIsFocused)
                    .foregroundColor(.black)
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
                Text("Task Priority")
                    .font(.headline)
                
                Picker("Priority", selection: $priority) {
                    ForEach(priorityLevels, id: \.self) { level in
                        Text(priorityString(for: level))
                            
                    }
                }
                .pickerStyle(.segmented)
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    nameIsFocused = false
                }
            }
        }
//        .accentColor(.teal) // Set the accent color for buttons and interactive elements
        .foregroundColor(.indigo) // Set the default text color
        .background(Color.gray.opacity(0.1))
    
        }
        
        
    }

    


