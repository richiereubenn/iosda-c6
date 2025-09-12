//
//  UserService.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 08/09/25.
//

import Foundation

protocol UserServiceProtocol {
    func register(_ request: User) async throws -> User
    func getCurrentUser() async throws -> User
        func getUserById(_ id: String) async throws -> User
    // Add other user-related functions here, e.g., login, fetch profile, etc.
}

class UserService: UserServiceProtocol {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func register(_ request: User) async throws -> User {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let bodyData = try encoder.encode(request)

        let response: APIResponse<User> = try await networkManager.request(
            endpoint: "/authN/v1/auth/register",
            method: .POST,
            body: bodyData
        )

        guard response.success else {
            let code = response.code ?? 0
            let message = response.message ?? "Unknown error"
            print("Registration failed with code \(code): \(message)")
            throw NetworkError.serverError(code)
        }

        guard let user = response.data else {
            throw NetworkError.decodingError
        }

        return user
    }
    func getCurrentUser() async throws -> User {
        let response: APIResponse<MeResponse> = try await networkManager.request(
            endpoint: "/authN/v1/auth/me",
            method: .GET
        )
        
        guard response.success else {
            throw NetworkError.serverError(response.code ?? -1)
        }
        
        // Safely unwrap response.data before accessing user and roles
        guard let meResponse = response.data else {
            throw NetworkError.decodingError
        }
        
        var user = meResponse.user
        user.role = meResponse.roles.first
        
        return user
    }


        
        // Get user by ID (if needed)
        func getUserById(_ id: String) async throws -> User {
            let response: UserDetailResponse = try await networkManager.request(
                endpoint: "/authN/v1/users/\(id)", // Adjust endpoint as needed
                method: .GET,
                body: nil
            )
            
            guard response.success else {
                throw NetworkError.serverError(response.code)
            }
            
            return response.data
        }
    
}
