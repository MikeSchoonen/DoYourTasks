//
//  AuthenticationService.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 04/11/2020.
//

import Foundation
import FirebaseAuth
import Combine

final class AuthenticationService: ObservableObject {
    @Published var user: User?
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        registerListener()
    }
    
    private func registerListener() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            print("DEBUG: Auth state changed")
            self.user = user
            
            guard let _ = user else {
                print("DEBUG: User isn't signed in")
                self.signIn()
                return
            }
        }
    }
    
    func signIn() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { authDataResult, error in
                guard let user = authDataResult?.user else { return }
                print("DEBUG: User signed in anonymously")
                self.user = user
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Unable to sign out user")
        }
    }
    
    func link(with email: String, password: String) -> AnyPublisher<Void, AuthenticationServiceError> {
        let emailCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        return Future<Void, AuthenticationServiceError> { promise in
            Auth.auth().currentUser?.link(with: emailCredential) { result, error in
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        promise(.failure(.operationNotAllowed))
                    case .emailAlreadyInUse:
                        promise(.failure(.emailAlreadyInUse))
                    case .invalidEmail:
                        promise(.failure(.invalidEmail))
                    case .weakPassword:
                        promise(.failure(.weakPassword))
                    case .providerAlreadyLinked:
                        promise(.failure(.providerAlreadyLinked))
                    case .credentialAlreadyInUse:
                        promise(.failure(.credentialAlreadyInUse))
                    default:
                        promise(.failure(.unknownError))
                    }
                } else if let user = result?.user {
                    Auth.auth().updateCurrentUser(user) { error in
                        if let _ = error {
                            promise(.failure(.unknownError))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func signIn(with email: String, password: String) -> AnyPublisher<Void, AuthenticationServiceError> {
        return Future<Void, AuthenticationServiceError> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        promise(.failure(.operationNotAllowed))
                    case .userDisabled:
                        promise(.failure(.userDisabled))
                    case .wrongPassword:
                        promise(.failure(.wrongPassword))
                    case .invalidEmail:
                        promise(.failure(.invalidEmail))
                    default:
                        promise(.failure(.unknownError))
                    }
                }
                
                if let user = authResult?.user {
                    Auth.auth().updateCurrentUser(user) { error in
                        if let _ = error {
                            promise(.failure(.unknownError))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func sendPasswordReset(to email: String) -> AnyPublisher<Void, AuthenticationServiceError> {
        return Future<Void, AuthenticationServiceError> { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .userNotFound:
                        promise(.failure(.userNotFound))
                    case .invalidEmail:
                        promise(.failure(.invalidEmail))
                    case .invalidRecipientEmail:
                        promise(.failure(.invalidRecipientEmail))
                    case .invalidSender:
                        promise(.failure(.invalidSender))
                    case .invalidMessagePayload:
                        promise(.failure(.invalidMessagePayload))
                    default:
                        promise(.failure(.unknownError))
                    }
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updatePassword(to password: String) -> AnyPublisher<Void, AuthenticationServiceError> {
        return Future<Void, AuthenticationServiceError> { promise in
            guard let user = Auth.auth().currentUser else {
                promise(.failure(.unknownError))
                return
            }
            
            user.updatePassword(to: password) { error in
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .userDisabled:
                        promise(.failure(.userDisabled))
                    case .weakPassword:
                        promise(.failure(.weakPassword))
                    case .operationNotAllowed:
                        promise(.failure(.operationNotAllowed))
                    case .requiresRecentLogin:
                        promise(.failure(.requiresRecentLogin))
                    default:
                        promise(.failure(.unknownError))
                    }
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }

    func updateEmail(to email: String, completion: @escaping (Result<Void, AuthenticationServiceError>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(.unknownError))
            return
        }
        user.updateEmail(to: email) { error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .invalidRecipientEmail:
                    completion(.failure(.invalidRecipientEmail))
                case .invalidSender:
                    completion(.failure(.invalidSender))
                case .invalidMessagePayload:
                    completion(.failure(.invalidMessagePayload))
                case .emailAlreadyInUse:
                    completion(.failure(.emailAlreadyInUse))
                case .invalidEmail:
                    completion(.failure(.invalidEmail))
                case .requiresRecentLogin:
                    completion(.failure(.requiresRecentLogin))
                default:
                    completion(.failure(.unknownError))
                }
            }

            completion(.success(()))
        }
    }
    
    func deleteAccount() -> AnyPublisher<Void, AuthenticationServiceError> {
        return Future<Void, AuthenticationServiceError> { promise in
            guard let user = Auth.auth().currentUser else {
                promise(.failure(.unknownError))
                return
            }
            
            user.delete { error in
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        promise(.failure(.operationNotAllowed))
                    case .requiresRecentLogin:
                        promise(.failure(.requiresRecentLogin))
                    default:
                        promise(.failure(.unknownError))
                    }
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }

//    func deleteAccount(completion: @escaping (Result<Void, AuthenticationServiceError>) -> Void) {
//        guard let user = Auth.auth().currentUser else {
//            completion(.failure(.unknownError))
//            return
//        }
//        user.delete { error in
//            if let error = error as NSError? {
//                switch AuthErrorCode(rawValue: error.code) {
//                case .operationNotAllowed:
//                    completion(.failure(.operationNotAllowed))
//                case .requiresRecentLogin:
//                    completion(.failure(.requiresRecentLogin))
//                default:
//                    completion(.failure(.unknownError))
//                }
//            }
//
//            completion(.success(()))
//        }
//    }
    
    // MARK: - Private functions
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let minPasswordLength = 8
        return password.count >= minPasswordLength
    }
    
//    private func storeUser(_ user: User) {
//        let userModel = UserModel(userID: user.uid, isAnonymous: user.isAnonymous, email: user.email)
//        do {
//            try self.db.collection("users").document(userModel.userID).setData(from: userModel)
//        } catch {
//            print("DEBUG: Failed to save userdata.")
//        }
//    }
}

enum AuthenticationServiceError: Error {
    case unknownError, operationNotAllowed, emailAlreadyInUse, invalidEmail, weakPassword, userDisabled, wrongPassword, userNotFound, invalidRecipientEmail, invalidSender, invalidMessagePayload, requiresRecentLogin, providerAlreadyLinked, credentialAlreadyInUse

    var description: String {
        switch self {
        case .unknownError:
            return "Something unexpected happend."
        case .operationNotAllowed:
            return "The given sign-in provider is disabled for this Firebase project."
        case .emailAlreadyInUse:
            return "The email address is already in use by another account."
        case .invalidEmail:
            return "The email address is badly formatted."
        case .weakPassword:
            return "The password must be 6 characters long or more."
        case .userDisabled:
            return "The user account has been disabled by an administrator."
        case .wrongPassword:
            return "The password is invalid or the user does not have a password."
        case .userNotFound:
            return "The given sign-in provider is disabled for this Firebase project."
        case .invalidRecipientEmail:
            return "Indicates an invalid recipient email was sent in the request."
        case .invalidSender:
            return "Indicates an invalid sender email is set in the console for this action."
        case .invalidMessagePayload:
            return "Indicates an invalid email template for sending update email."
        case .requiresRecentLogin:
            return "Updating a user’s password is a security sensitive operation that requires a recent login from the user."
        case .providerAlreadyLinked:
            return "This account is already linked."
        case .credentialAlreadyInUse:
            return "The credentials are already in use by another account."
        }
    }
}
