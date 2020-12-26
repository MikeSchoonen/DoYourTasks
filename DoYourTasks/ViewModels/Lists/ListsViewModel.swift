//
//  ListsViewModel.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 31/10/2020.
//

import Foundation
import Combine
import Resolver

final class ListsViewModel: ObservableObject {
    @Injected private var listsRepository: ListsRepository
    @Published private(set) var listCellViewModels: [ListCellViewModel] = []
    
    @Published var selectedSheet: ListsViewSheet? = nil
    @Published var showActionSheet = false
    @Published var listCellViewModel: ListCellViewModel? = nil
    @Published var indexSet: IndexSet? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        listsRepository.$lists.map { lists in
            lists.map { list in
                ListCellViewModel(list: list)
            }
        }
        .assign(to: \.listCellViewModels, on: self)
        .store(in: &cancellables)
    }
    
    func fetch() {
        listsRepository.fetch()
    }
    
    func edit(_ listCellViewModel: ListCellViewModel) {
        self.listCellViewModel = listCellViewModel
        $listCellViewModel
            .sink(receiveCompletion: { _ in
                self.listCellViewModel = nil
            }, receiveValue: { item in
                if item != nil {
                    self.selectedSheet = .edit
                }
            })
            .store(in: &cancellables)
    }
    
    func delete() {
        if let listCellViewModel = self.listCellViewModel {
            listsRepository.delete(listCellViewModel.list)
            self.listCellViewModel = nil
        } else if let indexSet = self.indexSet {
            let viewModels = indexSet.lazy.map { self.listCellViewModels[$0] }
            viewModels.forEach { listsRepository.delete($0.list) }
            self.indexSet = nil
        }
    }
    
    func requestDelete(_ listCellViewModel: ListCellViewModel) {
        self.listCellViewModel = listCellViewModel
        showActionSheet = true
    }
    
    func requestDelete(atOffsets indexSet: IndexSet) {
        self.indexSet = indexSet
        showActionSheet = true
    }
}
