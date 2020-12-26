//
//  ListsView.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 31/10/2020.
//

import SwiftUI

struct ListsView: View {
    @StateObject private var listsViewModel = ListsViewModel()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    ForEach(listsViewModel.listCellViewModels) { listCellViewModel in
                        NavigationLink(destination: TasksView(list: listCellViewModel.list)) {
                            HStack(alignment: .center) {
                                Image(systemName: "star")
                                Text(listCellViewModel.name)
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
                                    listsViewModel.edit(listCellViewModel)
                                } label: {
                                    HStack {
                                        Text("Edit")
                                        Image(systemName: "pencil")
                                    }
                                }

                                Button {
                                    listsViewModel.requestDelete(listCellViewModel)
                                } label: {
                                    HStack {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: listsViewModel.requestDelete(atOffsets:))
                }
                .listStyle(PlainListStyle())
                
                Button {
                    listsViewModel.selectedSheet = .add
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
            .navigationTitle("Lists")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        listsViewModel.selectedSheet = .settings
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(item: $listsViewModel.selectedSheet) { selectedSheet in
                switch selectedSheet {
                    case .add:
                        AddEditListView(list: nil)
                    case .edit:
                        if let list = listsViewModel.listCellViewModel?.list {
                            AddEditListView(list: list)
                        }
                    case .settings:
                        SettingsView()
                }
            }
            .actionSheet(isPresented: $listsViewModel.showActionSheet) {
                ActionSheet(
                    title: Text("Are you sure?"),
                    message: Text("All underlaying tasks will be deleted."),
                    buttons: [
                        .destructive(Text("Delete")) {
                            listsViewModel.delete()
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
}

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView()
    }
}
