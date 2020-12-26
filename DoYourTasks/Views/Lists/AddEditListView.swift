//
//  AddEditListView.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 01/11/2020.
//

import SwiftUI

struct AddEditListView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var addEditListViewModel: AddEditListViewModel
    
    init(list: ListModel?) {
        _addEditListViewModel = StateObject(wrappedValue: AddEditListViewModel(list: list))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $addEditListViewModel.list.name)
                }
            }
            .navigationTitle(addEditListViewModel.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        handleSaveTapped()
                    }
                    .disabled(!addEditListViewModel.modified)
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
        addEditListViewModel.save()
        dismiss()
    }
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddListView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditListView(list: nil)
    }
}
