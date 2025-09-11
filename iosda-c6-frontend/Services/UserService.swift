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
        encoder.keyEncodingStrategy = .convertToSnakeCase // This is important
        
        let bodyData = try encoder.encode(request)

        let response: APIResponse<User> = try await networkManager.request(
            endpoint: "/register", // Your registration endpoint
            method: .POST,
            body: bodyData
        )

        guard response.success else {
            // Throw a more specific error, perhaps using the message from the API
            throw NetworkError.serverError(0)
        }

        guard let user = response.data else {
            throw NetworkError.decodingError
        }

        return user
    }
}
