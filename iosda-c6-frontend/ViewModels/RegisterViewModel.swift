//
//  RegisterViewModel.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 08/09/25.
//


import Foundation

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var acceptedTerms: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var registrationSuccess: Bool = false
    @Published var errorMessage: String?
    
    
    private let networkManager = NetworkManager.shared
    
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !phone.isEmpty && !username.isEmpty && !password.isEmpty && acceptedTerms
    }
    
    func registerUser() {
        guard isFormValid else {
            errorMessage = "Please fill in all fields and accept the terms."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let newUser = User(
                    id: nil,
                    roleId: nil,
                    name: name,
                    phone: phone,
                    email: email,
                    username: username,
                    password: password,
                    acceptTosPrivacy: acceptedTerms
                )
                
                let registeredUser = try await userService.register(newUser)
                
                registrationSuccess = true
                print("Registration successful for user: \(registeredUser.username)")
                
            } catch let error as NetworkError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}
