//
//  AddEditListViewModel.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 01/11/2020.
//

import Foundation
import Combine
import Resolver

final class AddEditListViewModel: ObservableObject {
    @Injected private var listsRepository: ListsRepository
    
    @Published var list: ListModel
    @Published var modified = false
    
    private var isNewList: Bool
    private var cancellables = Set<AnyCancellable>()
    
    init(list: ListModel?) {
        if let list = list {
            isNewList = false
            self.list = list
        } else {
            isNewList = true
            self.list = ListModel.new
        }
        
        $list
            .dropFirst()
            .sink { [weak self] _ in
                self?.modified = true
            }
            .store(in: &cancellables)
    }
    
    var navigationTitle: String {
        isNewList ? "Add List" : "Edit List"
    }
    
    func save() {
        isNewList ? add() : update()
    }
    
    private func add() {
        listsRepository.add(list)
    }
    
    private func update() {
        listsRepository.update(list)
    }
}
