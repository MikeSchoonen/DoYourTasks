//
//  SettingsView.swift
//  DoYourTasks
//
//  Created by Mike Schoonen on 01/11/2020.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var settingsViewModel = SettingsViewModel()
    @State private var selectedSheet: SettingsViewSheet? = nil
    @State private var presentInfoHUD = false
    @State private var presentDeleteAccount = false
    
    private var appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    
    var body: some View {
        ZStack(alignment: .top) {
            content
            
            InfoHUD(title: "Success", systemImage: "person")
                .offset(y: presentInfoHUD ? 0 : -100)
                .animation(.easeOut)
        }
    }
    
    var content: some View {
        NavigationView {
            Form {
                Section(header: Text("GENERAL")) {
                    Text("userID: \(settingsViewModel.userID)")
                }
                
                Section(header: Text("ACCOUNT")) {
                    Button("Create account") {
                        selectedSheet = .signUp
                    }
                    Button("Login account") {
                        selectedSheet = .signIn
                    }
                    Button("Sign out") {
                        settingsViewModel.signOut()
                    }
                    Button(action: {
                        presentDeleteAccount = true
                    }, label: {
                        Text("Delete account")
                            .foregroundColor(.red)
                    })
                }
                
                Section(header: Text("FEEDBACK")) {
                    Button("Suggest a feature") {
                        selectedSheet = .mail
                    }
                }
                
                Section(header: Text("SETTINGS")) {
                    Button("Reset all settings") {
                        print("reset settings")
                    }
                }
                
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version:")
                        Spacer()
                        Text(appVersion)
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(item: $selectedSheet) { selectedSheet in
                switch selectedSheet {
                    case .signUp:
                        SignInUpView(selectedSheet: $selectedSheet, presentInfoHUD: $presentInfoHUD, mode: .signUp)
                    case .signIn:
                        SignInUpView(selectedSheet: $selectedSheet, presentInfoHUD: $presentInfoHUD, mode: .signIn)
                    case .mail:
                        MailView()
                }
            }
            .alert(isPresented: $settingsViewModel.showError) {
                Alert(
                    title: Text("Failed to authenticate"),
                    message: Text(settingsViewModel.errorMessage),
                    dismissButton: .cancel()
                )
            }
            .actionSheet(isPresented: $presentDeleteAccount) {
                ActionSheet(
                    title: Text("Delete account"),
                    message: Text("All your details will be lost."),
                    buttons: [
                        .destructive(
                            Text("Delete"),
                            action: { settingsViewModel.deleteAccount() }
                        ),
                        .cancel()
                    ]
                )
            }
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
