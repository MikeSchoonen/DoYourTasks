//
//  DependencyInjection.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 31/10/2020.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { FirestoreListsRepository() as ListsRepository }.scope(application)
        register { FirestoreTasksRepository() as TasksRepository }.scope(application)
        register { AuthenticationService() as AuthenticationService }.scope(application)
    }
}
