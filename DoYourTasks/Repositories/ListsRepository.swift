//
//  ListsRepository.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 01/11/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Resolver
import Combine

class BaseListsRepository: ObservableObject {
    @Published var lists: [ListModel] = []
}

protocol ListsRepository: BaseListsRepository {
    func add(_ list: ListModel)
    func update(_ list: ListModel)
    func delete(_ list: ListModel)
    func fetch()
}

final class TestDataListsRepository: BaseListsRepository, ListsRepository {
    
    func add(_ list: ListModel) {
        lists.append(list)
    }
    
    func update(_ list: ListModel) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index] = list
        }
    }
    
    func delete(_ list: ListModel) {
        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists.remove(at: index)
        }
    }
    
    func fetch() {
        lists = testLists
    }
    
}

final class FirestoreListsRepository: BaseListsRepository, ListsRepository {
    @Injected var authenticationService: AuthenticationService
    @LazyInjected var tasksRepository: TasksRepository
    
    private let db = Firestore.firestore()
    private let listsPath = "lists"
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
        
        authenticationService.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetch()
            }
            .store(in: &cancellables)
    }
    
    func add(_ list: ListModel) {
        var userList = list
        userList.userID = userID
        
        do {
            let _ = try db.collection(listsPath).addDocument(from: userList)
        } catch {
            print("DEBUG: Unable to add list.")
        }
    }
    
    func update(_ list: ListModel) {
        guard let listID = list.id else {
            print("DEBUG: Unable to update list, listID is missing.")
            return
        }
        
        do {
            let _ = try db.collection(listsPath).document(listID).setData(from: list)
        } catch {
            print("DEBUG: Unable to update list.")
        }
    }
    
    func delete(_ list: ListModel) {
        guard let listID = list.id else {
            print("DEBUG: Unable to delete list, listID is missing.")
            return
        }
        
        db.collection(listsPath).document(listID).delete { error in
            if let error = error {
                print("DEBUG: Unable to delete list, with error \(error.localizedDescription)")
            } else {
                self.tasksRepository.deleteTasks(for: list)
            }
        }
    }
    
    func fetch() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
        }
        
        print("DEBUG: UserID = \(userID)")
        listenerRegistration = db.collection(listsPath).whereField("userID", isEqualTo: userID).order(by: "createdAt", descending: true).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("DEBUG: No list documents.")
                return
            }
            
            self.lists = documents.compactMap { queryDocumentSnapshot in
                do {
                    return try queryDocumentSnapshot.data(as: ListModel.self)
                } catch {
                    print("DEBUG: Unable to decode ListModel while fetching documents.")
                    return nil
                }
            }
        }
    }
}
