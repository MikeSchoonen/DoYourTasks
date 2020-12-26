//
//  ListModel.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 31/10/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ListModel: Codable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    var userID: String?
    var name: String
    @ServerTimestamp var createdAt: Timestamp?
    
    static var placeholder: ListModel {
        ListModel(id: "aaa", name: "List 1")
    }
    
    static var new: ListModel {
        ListModel(name: "")
    }
}

#if DEBUG
let testLists: [ListModel] = [
    .init(id: "aaa", name: "First list", createdAt: Timestamp(date: Date())),
    .init(id: "bbb", name: "Second list", createdAt: Timestamp(date: Date())),
    .init(id: "ccc", name: "Third list", createdAt: Timestamp(date: Date()))
]
#endif
