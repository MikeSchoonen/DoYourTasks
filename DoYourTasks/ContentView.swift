//
//  ContentView.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 06/11/2020.
//

import SwiftUI
import Resolver

struct ContentView: View {
    @Injected var authenticationService: AuthenticationService
    
    var body: some View {
        Group {
//            SignUpView()
//            if authenticationService.user != nil {
//                ListsView()
//            } else {
//                Text("Authentication Screen")
//            }
        }
        .animation(.easeInOut)
        .transition(.move(edge: .bottom))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
