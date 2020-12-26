//
//  FirestoreTasksRepository.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 31/10/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Resolver
import Combine

class BaseTasksRepository: ObservableObject {
    @Published var tasks: [Task] = []
}

protocol TasksRepository: BaseTasksRepository {
    func add(_ task: Task)
    func update(_ task: Task)
    func delete(_ task: Task)
    func fetch(for list: ListModel)
    func deleteTasks(for list: ListModel)
}

final class TestDataTasksRepository: BaseTasksRepository, TasksRepository {
    private var allTasks: [Task] = testTasks
    
    func add(_ task: Task) {
        tasks.append(task)
    }
    
    func update(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func delete(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
        }
    }
    
    func fetch(for list: ListModel) {
        tasks = testTasks.compactMap { $0.listID == list.id ? $0 : nil }
    }
    
    func deleteTasks(for list: ListModel) {
        tasks.forEach {
            if $0.listID == list.id {
                if let index = tasks.firstIndex(where: { $0.listID == list.id }) {
                    tasks.remove(at: index)
                }
            }
        }
    }
    
}

final class LocalTasksRepository: BaseTasksRepository, TasksRepository {
    private let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    private var allTasks: [Task] = []
    
    override init() {
        super.init()
        load()
    }
    
    func add(_ task: Task) {
        allTasks.append(task)
        save()
    }
    
    func update(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            save()
        }
    }
    
    func delete(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
            save()
        }
    }
    
    func fetch(for list: ListModel) {
        self.tasks = allTasks.compactMap { $0.listID == list.id ? $0 : nil }
    }
    
    func deleteTasks(for list: ListModel) {
        tasks.forEach {
            if $0.listID == list.id {
                if let index = tasks.firstIndex(where: { $0.listID == list.id }) {
                    tasks.remove(at: index)
                }
            }
        }
    }
    
    private func save() {
        do {
            if let url = urls.first {
                let fileURL = url.appendingPathComponent("tasks").appendingPathExtension("json")
                let data = try JSONEncoder().encode(tasks)
                try data.write(to: fileURL, options: .atomic)
            }
        } catch {
            print("DEBUG: Unable to save data to json file.")
        }
    }
    
    private func load() {
        do {
            if let url = urls.first {
                let fileURL = url.appendingPathComponent("tasks").appendingPathExtension("json")
                let data = try Data(contentsOf: fileURL)
                let tasks = try JSONDecoder().decode([Task].self, from: data)
                self.allTasks = tasks
            }
        } catch {
            print("DEBUG: Failed decoding and load data from disk.")
        }
    }
}

final class FirestoreTasksRepository: BaseTasksRepository, TasksRepository {
    @LazyInjected var authenticationService: AuthenticationService
    
    private let db = Firestore.firestore()
    private let tasksPath = "tasks"
    private var listenerRegistration: ListenerRegistration?
    private var userID = "unknown"
    
    private var cancellables: Set<AnyCancellable> = []
    
    override init() {
        super.init()
        
        authenticationService.$user
            .compactMap { user in
                user?.uid
            }
            .assign(to: \.userID, on: self)
            .store(in: &cancellables)
    }
    
    public func add(_ task: Task) {
        var userTask = task
        userTask.userID = userID
        
        do {
            let _ = try db.collection(tasksPath).addDocument(from: userTask)
        } catch {
            print("DEBUG: Unable to add task.")
        }
    }
    
    public func update(_ task: Task) {
        guard let taskID = task.id else {
            print("DEBUG: Can't update task, taskID is missing.")
            return
        }
        
        do {
            let _ = try db.collection(tasksPath).document(taskID).setData(from: task)
        } catch {
            print("DEBUG: Unable to update task.")
        }
    }
    
    public func delete(_ task: Task) {
        guard let taskID = task.id else {
            print("DEBUG: Can't update task, taskID is missing.")
            return
        }
        
        db.collection(tasksPath).document(taskID).delete { error in
            print("DEBUG: Error deleting task with ID: \(taskID)")
        }
    }
    
    public func fetch(for list: ListModel) {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
        }
        
        guard let listID = list.id else {
            print("DEBUG: Unable to fetch tasks for \(list.name) because ID is missing.")
            return
        }
        
        listenerRegistration = db.collection(tasksPath).whereField("listID", isEqualTo: listID).whereField("userID", isEqualTo: userID).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("DEBUG: No task documents.")
                return
            }
            
            self.tasks = documents.compactMap { queryDocumentSnapshot in
                try? queryDocumentSnapshot.data(as: Task.self)
            }
        }
    }
    
    public func deleteTasks(for list: ListModel) {
        guard let listID = list.id else {
            print("DEBUG: Unable to delete all tasks for \(list.name) becaus listID is missing.")
            return
        }
        
        db.collection(tasksPath).whereField("listID", isEqualTo: listID).getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("DEBUG: No task documents")
                return
            }
            
            let batch = self.db.batch()
            
            documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            
            batch.commit()
        }
    }
}
