//
//  AddEditTaskViewModel.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 01/11/2020.
//

import Foundation
import Combine
import Resolver

final class AddEditTaskViewModel: ObservableObject {
    @Injected private var tasksRepository: TasksRepository
    
    @Published var task: Task
    @Published var modified = false
    
    private var list: ListModel
    private var isNewTask: Bool
    private var cancellables = Set<AnyCancellable>()
    
    init(list: ListModel, task: Task?) {
        self.list = list
        
        if let task = task {
            isNewTask = false
            self.task = task
        } else {
            isNewTask = true
            self.task = Task.new
        }
        
        $task
            .dropFirst()
            .sink { [weak self] task in
                self?.modified = true
            }
            .store(in: &cancellables)
    }
    
    var navigationTitle: String {
        isNewTask ? "Add Task" : "Edit Task"
    }
    
    func save() {
        isNewTask ? add() : update()
    }
    
    private func add() {
        guard let listID = list.id else {
            print("DEBUG: Unable to add task from VM, listID is missing.")
            return
        }
        
        var userTask = task
        userTask.listID = listID
        
        tasksRepository.add(userTask)
    }
    
    private func update() {
        guard let listID = list.id else {
            print("DEBUG: Unable to add task from VM, listID is missing.")
            return
        }
        
        var userTask = task
        userTask.listID = listID
        
        tasksRepository.update(userTask)
    }
}
