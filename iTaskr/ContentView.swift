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
    
    private func priorityColor(for priority: Int16) -> Color {
        switch priority {
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
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(taskName)
                                            .font(.system(size: 22, design: .rounded))
                                        
                                            .foregroundColor(.primary)
                                        Text("\(hours > 0 ? "\(hours) \(hours == 1 ? "hour" : "hours") " : "")\(minutes > 0 ? "\(minutes) \(minutes == 1 ? "minute" : "minutes")" : "")")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                    }
                                    Spacer()
                                    Image(systemName: "envelope")
                                        .font(.title)
                                        .foregroundColor(priorityColor(for: task.priority))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(priorityColor(for: task.priority).opacity(0.3))
                                .cornerRadius(10)
                        }
                            
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            
                          
                       
                            
                        
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
                
                .sheet(isPresented: $showingAddScreen){
                    AddTaskView()
                }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
