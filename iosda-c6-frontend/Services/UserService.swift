//
//  UserService.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 08/09/25.
//

import Foundation

protocol UserServiceProtocol {
    func register(_ request: User) async throws -> User
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
}
