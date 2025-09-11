import Foundation

protocol LoginServiceProtocol {
    func login(username: String, password: String) async throws -> User
}
class LoginService: LoginServiceProtocol {
    private let networkManager: NetworkManager
    private let userService: UserServiceProtocol
    
    init(networkManager: NetworkManager = .shared,
         userService: UserServiceProtocol = UserService()) {
        self.networkManager = networkManager
        self.userService = userService
    }

    func login(username: String, password: String) async throws -> User {
        let requestBody = [
            "identifier": username,
            "password": password
        ]

        let bodyData = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        // Step 1: Login to get tokens
        let loginResponse: LoginResponse = try await networkManager.request(
            endpoint: "/authN/v1/auth/login",
            method: .POST,
            body: bodyData
        )

        guard loginResponse.success else {
            throw NetworkError.serverError(loginResponse.code)
        }
        
        print("DEBUG: Login successful, got tokens")
        
        // Step 2: Store tokens (you might want to save these to Keychain/UserDefaults)
        // For now, we'll assume NetworkManager handles token storage
        
        // Step 3: Fetch complete user details including role
        do {
            let completeUser = try await userService.getCurrentUser()
            print("DEBUG: Fetched complete user details")
            print("DEBUG: User role: \(completeUser.role?.name ?? "No role")")
            print("DEBUG: User role ID: \(completeUser.role?.id ?? "No role ID")")
            
            return completeUser
        } catch {
            print("DEBUG: Failed to fetch user details: \(error)")
            
            // Fallback: return basic user from login response
            // This ensures login doesn't fail completely if user detail fetch fails
            print("DEBUG: Using basic user info from login response")
            return loginResponse.data.user
        }
    }
}
