//
//  LoginViewModel.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 08/09/25.
//


import SwiftUI
@MainActor
class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var loggedInUser: User?
    
    private let loginService: LoginServiceProtocol
    
    init(loginService: LoginServiceProtocol = LoginService()) {
        self.loginService = loginService
    }
    
    var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    func login() {
        guard isFormValid else {
            errorMessage = "Please enter both username and password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                print("DEBUG: Starting login process...")
                let user = try await loginService.login(username: username, password: password)
                
                print("DEBUG: Login process completed")
                print("DEBUG: User received: \(user.name)")
                print("DEBUG: User role: \(user.role?.name ?? "No role")")
                
                self.loggedInUser = user
                if let userId = NetworkManager.shared.getUserIdFromToken() {
                    print("✅ Logged in user ID: \(userId)")
                } else {
                    print("⚠️ Failed to decode user ID from token")
                }
                
            } catch {
                print("DEBUG: Login failed with error: \(error)")
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
