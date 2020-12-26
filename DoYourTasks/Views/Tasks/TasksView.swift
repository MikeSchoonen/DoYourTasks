//
//  TasksView.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 31/10/2020.
//

import SwiftUI

struct TasksView: View {
    @StateObject private var tasksViewModel: TasksViewModel
    
    private var list: ListModel
    
    init(list: ListModel) {
        self.list = list
        _tasksViewModel = StateObject(wrappedValue: TasksViewModel(list: list))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(tasksViewModel.taskCellViewModels) { taskCellViewModel in
                    HStack(alignment: .center) {
                        Image(systemName: "circle")
                        Text(taskCellViewModel.name)
                            .font(.body)
                        
                        if taskCellViewModel.task.priority != .none {
                            Spacer()
                            Text(taskCellViewModel.priority)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .contextMenu {
                        Button {
                            print("favotire")
                        } label: {
                            HStack {
                                Text("Favorite")
                                Image(systemName: "star")
                            }
                        }
                        
                        Button {
                            tasksViewModel.edit(taskCellViewModel)
                        } label: {
                            HStack {
                                Text("Edit")
                                Image(systemName: "pencil")
                            }
                        }

                        Button {
                            tasksViewModel.delete(taskCellViewModel)
                        } label: {
                            HStack {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
                .onDelete(perform: tasksViewModel.delete(atOffsets:))
            }
            .listStyle(PlainListStyle())
            
            Button {
                tasksViewModel.selectedSheet = .add
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("New List")
                }
            }
            .padding()
            .accentColor(.red)
        }
        .navigationTitle("Tasks")
        .onAppear(perform: tasksViewModel.fetch)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    tasksViewModel.selectedSheet = .settings
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(item: $tasksViewModel.selectedSheet) { selectedSheet in
            switch selectedSheet {
            case .add:
                AddEditTaskView(list: list, task: nil)
            case .edit:
                if let taskCellViewModel = tasksViewModel.taskCellViewModel {
                    AddEditTaskView(list: list, task: taskCellViewModel.task)
                }
            case .settings:
                SettingsView()
            }
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TasksView(list: ListModel.placeholder)
                .navigationTitle("Tasks")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
