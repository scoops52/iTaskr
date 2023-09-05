//
//  ContentView.swift
//  iTaskr
//
//  Created by Sean Cooper on 8/30/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.displayPriority)
    ]) var tasks: FetchedResults<Task>
    @EnvironmentObject var timerModel: TimerModel
    @State private var showingAddScreen = false
    
    func hoursAndMinutes(from totalSeconds: Int) -> (hours: Int, minutes: Int) {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        return (hours, minutes)
    }
    
    func deleteTasks(at offsets: IndexSet) {
        withAnimation{
            for offset in offsets {
                let task = tasks[offset]
                moc.delete(task)
            }
            
            try? moc.save()
        }
    }
    
    func moveItem(at sets: IndexSet, destination: Int) {
        let itemToMove = sets.first!
        
        if itemToMove < destination {
            var startIndex = itemToMove + 1
            let endIndex = destination - 1
            var startOrder = tasks[itemToMove].displayPriority
            while startIndex <= endIndex {
                tasks[startIndex].displayPriority = startOrder
                startOrder = startOrder + 1
                startIndex = startIndex + 1
            }
            tasks[itemToMove].displayPriority = startOrder
        }
        else if destination < itemToMove {
            var startIndex = destination
            let endIndex = itemToMove - 1
            var startOrder = tasks[destination].displayPriority + 1
            let newOrder = tasks[destination].displayPriority
            while startIndex <= endIndex {
                tasks[startIndex].displayPriority = startOrder
                startOrder = startOrder + 1
                startIndex = startIndex + 1
            }
            tasks[itemToMove].displayPriority = newOrder
        }
        do {
            try moc.save()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    if let taskName = task.name {
                        let totalDurationInSeconds = Int(task.duration)
                        let (hours, minutes) = hoursAndMinutes(from: totalDurationInSeconds)
                        
                            NavigationLink {
                                TaskView(task: task)
//                                TimerView()
                                    .environmentObject(timerModel)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(taskName)
                                        .font(.title)
                                        .foregroundColor(Color.purple)
                                    Text("\(hours > 0 ? "\(hours) \(hours == 1 ? "hour" : "hours")" : "") \(minutes > 0 ? "\(minutes) \(minutes == 1 ? "minute" : "minutes")" : "")")
                                        .font(.subheadline)
                                        .foregroundColor(Color.cyan)
                                    
                                }
                            }
                            .listRowBackground(Color.clear)
                            .padding()
                          
                       
                            
                        
                        }
                        

                }
                .onMove(perform: moveItem)
                .onDelete(perform: deleteTasks)
            }
            
                .navigationTitle("Tasks")
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingAddScreen.toggle()
                        } label: {
                            Label("Add task", systemImage: "plus")
                        }
                    }
                }
                .accentColor(.teal) // Set the accent color for buttons and interactive elements
                            .foregroundColor(.indigo) // Set the default text color
                            .background(Color.gray.opacity(0.1))
                .sheet(isPresented: $showingAddScreen){
                    AddTaskView(taskCount: tasks.count)
                }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
