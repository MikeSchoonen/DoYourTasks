//
//  SettingsViewModel.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 17/11/2020.
//

import SwiftUI
import Resolver
import Combine

final class SettingsViewModel: ObservableObject {
    @LazyInjected var authenticationService: AuthenticationService
    
    @Published var errorMessage = ""
    @Published var showError = false
    
    var userID = "unknown"
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        authenticationService.$user
            .compactMap { user in
                user?.uid
            }
            .assign(to: \.userID, on: self)
            .store(in: &cancellables)
    }
    
    func signOut() {
        authenticationService.signOut()
    }
    
    func deleteAccount() {
        authenticationService.deleteAccount().sink { [weak self] completion in
            switch completion {
            case let .failure(error):
                self?.errorMessage = error.description
                self?.showError = true
            case .finished:
                break
            }
        } receiveValue: { _ in
            
        }
        .store(in: &cancellables)
    }
}
