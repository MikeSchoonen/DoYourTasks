//
//  SignInUpView.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 25/12/2020.
//

import SwiftUI

struct SignInUpView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var signInUpViewModel: SignInUpViewModel
    @Binding var selectedSheet: SettingsViewSheet?
    @Binding var presentInfoHUD: Bool
    
    let mode: SignInUpMode
    
    init(
        selectedSheet: Binding<SettingsViewSheet?>,
        presentInfoHUD: Binding<Bool>,
        mode: SignInUpMode
    ) {
        self._selectedSheet = selectedSheet
        self._presentInfoHUD = presentInfoHUD
        self.mode = mode
        
        let signInUpViewModel = SignInUpViewModel(selectedSheet: selectedSheet, presentInfoHUD: presentInfoHUD, mode: mode)
        self._signInUpViewModel = StateObject(wrappedValue: signInUpViewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Form {
                        Section(footer: Text(signInUpViewModel.inlineErrorForPassword).foregroundColor(.red)) {
                            TextField("Email", text: $signInUpViewModel.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            SecureField("Password", text: $signInUpViewModel.password)
                            
                            if mode == .signUp {
                                SecureField("Repeat password", text: $signInUpViewModel.repeatPassword)
                            }
                        }
                    }
                    
                    Button(action: {
                        signInUpViewModel.authenticate()
                    }, label: {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 60)
                            .overlay(
                                Text(signInUpViewModel.buttonText)
                                    .foregroundColor(.white)
                            )
                    })
                    .padding()
                    .disabled(!signInUpViewModel.isValid)
                }
                if signInUpViewModel.isLoading {
                    ProgressHUD(placeholder: signInUpViewModel.progressText)
                }
            }
            .navigationTitle(signInUpViewModel.buttonText)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }

        }
        .alert(isPresented: $signInUpViewModel.showError) {
            Alert(title: Text("Failed to authenticate"), message: Text(signInUpViewModel.errorMessage), dismissButton: .cancel())
        }
    }
}

struct SignInUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignInUpView(selectedSheet: .constant(nil), presentInfoHUD: .constant(false), mode: .signUp)
    }
}
