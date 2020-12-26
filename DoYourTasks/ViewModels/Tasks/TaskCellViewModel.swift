//
//  TaskCellViewModel.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 01/11/2020.
//

import SwiftUI
import Combine
import Resolver

final class TaskCellViewModel: Identifiable, ObservableObject {
    @Injected private var tasksRepository: TasksRepository
    @Published var task: Task
    
    private var cancellables = Set<AnyCancellable>()
    
    public var id = ""
    
    init(task: Task) {
        self.task = task
        
        $task
            .compactMap { $0.id }
            .assign(to: \.id, on: self)
            .store(in: &cancellables)
        
        $task
            .dropFirst()
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .sink { [weak self] task in
                self?.tasksRepository.update(task)
            }
            .store(in: &cancellables)
    }
    
    var name: String {
        task.name
    }
    
    var priority: String {
        task.priority.name
    }
}
