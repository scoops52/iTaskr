//
//  EditTaskView.swift
//  iTaskr
//
//  Created by Sean Cooper on 9/5/23.
//

import SwiftUI


import CoreData
import SwiftUI



struct EditTaskView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: []) private var tasks: FetchedResults<Task>

   
    @StateObject var task: Task
    @State private var name = ""
    @State private var durationHours = 0
    @State private var durationMinutes = 0
    @State private var priority = 1
    
    @FocusState private var nameIsFocused: Bool
    @State private var showingDeleteAlert = false
    
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
        
        task.name = name
        task.duration = setTime
        task.timeRemaining = setTime
        task.priority = Int16(priority)
        try? moc.save()
       
    }
    
    func deleteTask() {
        moc.delete(task)
        try? moc.save()
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
                        Text("Edit Task")
                    }
                }
            }
            
            Section {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName:"minus.circle.fill")
                        Text("Delete Task")
                            
                    }
                    .foregroundColor(.red)
                }
            }
            
            
            
        }
        .onAppear{
                    name = task.name ?? ""
                    durationHours = Int(task.duration / 3600)
                    durationMinutes = Int((task.duration % 3600) / 60)
                    priority = Int(task.priority)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    nameIsFocused = false
                }
                
            }
        }
        .alert("Are you sure you want to delete this task?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteTask()
                dismiss()
            }
        }
        
//        .accentColor(.teal) // Set the accent color for buttons and interactive elements
        .foregroundColor(.indigo) // Set the default text color
        .background(Color.gray.opacity(0.1))
    
        }
        
        
    }

    




