//
//  Task.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 31/10/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Task: Codable, Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    var listID: String
    var userID: String?
    var name: String
    var priority: Priority
    var completed: Bool
    @ServerTimestamp var createdAt: Timestamp?
    
    static var placeholder: Task {
        Task(listID: "", name: "Hello World", priority: .medium, completed: false)
    }
    
    static var new: Task {
        Task(listID: "", name: "", priority: .none, completed: false)
    }
    
    enum Priority: Int, Codable, CaseIterable {
        case none = 0
        case low
        case medium
        case high
        
        var name: String {
            switch self {
            case .none:
                return "None"
            case .low:
                return "Low"
            case .medium:
                return "Medium"
            case .high:
                return "High"
            }
        }
    }
}

#if DEBUG
let testTasks: [Task] = [
    .init(listID: "aaa", name: "First task in list with ID: aaa", priority: .none, completed: false),
    .init(listID: "aaa", name: "Second task in list with ID: aaa", priority: .medium, completed: true),
    .init(listID: "bbb", name: "First task in list with ID: bbb", priority: .none, completed: false),
    .init(listID: "bbb", name: "Second task in list with ID: bbb", priority: .medium, completed: true),
    .init(listID: "ccc", name: "First task in list with ID: ccc", priority: .none, completed: false),
    .init(listID: "ccc", name: "Second task in list with ID: ccc", priority: .medium, completed: true)
]
#endif
