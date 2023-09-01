//
//  ContentView.swift
//  iTaskr
//
//  Created by Sean Cooper on 8/30/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var tasks: FetchedResults<Task>
    
    @State private var showingAddScreen = false
    
    func hoursAndMinutes(from totalSeconds: Int) -> (hours: Int, minutes: Int) {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        return (hours, minutes)
    }
    
    func deleteTasks(at offsets: IndexSet) {
        for offset in offsets {
            let task = tasks[offset]
            moc.delete(task)
        }
        
        try? moc.save()
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    if let taskName = task.name {
                        let totalDurationInSeconds = Int(task.duration)
                        let (hours, minutes) = hoursAndMinutes(from: totalDurationInSeconds)
                        Section {
                            NavigationLink {
                                TaskView(task: task)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(taskName)
                                        .font(.headline)
                                    Text("\(hours)h \(minutes)m")
                                        .font(.subheadline)
                                }
                            }
                        }
                    
                    }
                }
                .onDelete(perform: deleteTasks)
            }
                .navigationTitle("iTaskr")
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
