//
//  SignInUpViewModel.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 25/12/2020.
//

import SwiftUI
import Combine
import Resolver

class SignInUpViewModel: ObservableObject {
    @Injected private var authenticationService: AuthenticationService
    @Binding var selectedSheet: SettingsViewSheet?
    @Binding var presentInfoHUD: Bool {
        didSet {
            if presentInfoHUD == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.presentInfoHUD = false
                }
            }
        }
    }
    
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false
    
    @Published var email = ""
    @Published var password = ""
    @Published var repeatPassword = ""
    
    @Published var isValid = false
    @Published var inlineErrorForPassword = ""
    
    let mode: SignInUpMode
    
    private static let emailPredicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    private static let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        selectedSheet: Binding<SettingsViewSheet?>,
        presentInfoHUD: Binding<Bool>,
        mode: SignInUpMode
    ) {
        self._selectedSheet = selectedSheet
        self._presentInfoHUD = presentInfoHUD
        self.mode = mode
        
        isPasswordValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { passwordStatus in
                switch passwordStatus {
                case .empty: return "Password can not be empty."
                case .notStrongEnough: return "Password is to weak."
                case .repeatedPasswordWrong: return "Passwords do not match."
                case .valid: return ""
                }
            }
            .assign(to: \.inlineErrorForPassword, on: self)
            .store(in: &cancellables)
        
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
    }
    
    var buttonText: String {
        switch mode {
        case .signUp: return "Register"
        case .signIn: return "Login"
        }
    }
    
    var progressText: String {
        switch mode {
        case .signUp: return "Signing up"
        case .signIn: return "Signing in"
        }
    }
    
    private var isEmailValidPublisher: AnyPublisher<Bool, Never> {
        $email
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { Self.emailPredicate.evaluate(with: $0) }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    private var arePasswordsEqualPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $repeatPassword)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { $0 == $1 }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordStrongPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { Self.passwordPredicate.evaluate(with: $0) }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordValidPublisher: AnyPublisher<PasswordStatus, Never> {
        if mode == .signUp {
            return Publishers.CombineLatest3(isPasswordEmptyPublisher, isPasswordStrongPublisher, arePasswordsEqualPublisher)
                .map {
                    if $0 { return .empty }
                    if !$1 { return .notStrongEnough }
                    if !$2 { return .repeatedPasswordWrong }
                    return .valid
                }
                .eraseToAnyPublisher()
        } else {
            return Just(.valid).eraseToAnyPublisher()
        }
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isEmailValidPublisher, isPasswordValidPublisher)
            .map { $0 && $1 == .valid }
            .eraseToAnyPublisher()
    }
    
    func authenticate() {
        self.isLoading = true
        if mode == .signUp {
            authenticationService.link(with: email, password: password).sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case let .failure(error):
                    self?.errorMessage = error.description
                    self?.showError = true
                case .finished:
                    self?.selectedSheet = nil
                    self?.presentInfoHUD = true
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
        } else {
            authenticationService.signIn(with: email, password: password).sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case let .failure(error):
                    self?.errorMessage = error.description
                    self?.showError = true
                case .finished:
                    self?.selectedSheet = nil
                    self?.presentInfoHUD = true
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
        }
    }
}
