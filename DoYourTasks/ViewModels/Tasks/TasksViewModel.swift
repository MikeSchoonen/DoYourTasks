//
//  TasksViewModel.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 01/11/2020.
//

import Foundation
import Combine
import Resolver

final class TasksViewModel: ObservableObject {
    @Injected private var tasksRepository: TasksRepository
    @Published private(set) var taskCellViewModels: [TaskCellViewModel] = []
    @Published var taskCellViewModel: TaskCellViewModel? = nil
    @Published var selectedSheet: TasksViewSheet? = nil
    @Published var indexSet: IndexSet? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private(set) var list: ListModel
    
    init(list: ListModel) {
        self.list = list
    }
    
    func fetch() {
        tasksRepository.fetch(for: list)
        
        tasksRepository.$tasks.map { tasks in
            tasks.map { task in
                TaskCellViewModel(task: task)
            }
        }
        .assign(to: \.taskCellViewModels, on: self)
        .store(in: &cancellables)
    }
    
    func edit(_ taskCellViewModel: TaskCellViewModel) {
        self.taskCellViewModel = taskCellViewModel
        $taskCellViewModel
            .sink { completion in
                self.taskCellViewModel = nil
            } receiveValue: { item in
                if item != nil {
                    self.selectedSheet = .edit
                }
            }
            .store(in: &cancellables)
    }
    
    func delete(atOffsets indexSet: IndexSet) {
        let viewModels = indexSet.lazy.map { self.taskCellViewModels[$0] }
        viewModels.forEach { tasksRepository.delete($0.task) }
    }
    
    func delete(_ taskCellViewModel: TaskCellViewModel) {
        tasksRepository.delete(taskCellViewModel.task)
    }
}
