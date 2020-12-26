//
//  AddEditTaskView.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 01/11/2020.
//

import SwiftUI

struct AddEditTaskView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var addEditTaskViewModel: AddEditTaskViewModel
    
    init(list: ListModel, task: Task?) {
        _addEditTaskViewModel = StateObject(wrappedValue: AddEditTaskViewModel(list: list, task: task))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $addEditTaskViewModel.task.name)
                    
                    Picker("Select a priority", selection: $addEditTaskViewModel.task.priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            Text(priority.name)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle(addEditTaskViewModel.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        handleSaveTapped()
                    }
                    .disabled(!addEditTaskViewModel.modified)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        handleCancelTapped()
                    }
                }
            }
        }
    }
    
    private func handleCancelTapped() {
        dismiss()
    }
    
    private func handleSaveTapped() {
        addEditTaskViewModel.save()
        dismiss()
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditTaskView(list: ListModel.placeholder, task: nil)
    }
}
