//
//  MultipleSheets.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 01/11/2020.
//

import Foundation

enum ListsViewSheet: Int, Identifiable {
    var id: Int { rawValue }
    case add, edit, settings
}

enum TasksViewSheet: Int, Identifiable {
    var id: Int { rawValue }
    case add, edit, settings
}

enum SettingsViewSheet: Int, Identifiable {
    var id: Int { rawValue }
    case signUp, signIn, mail
}
