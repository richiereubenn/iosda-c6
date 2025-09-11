import Foundation

protocol LoginServiceProtocol {
    func login(username: String, password: String) async throws -> User
}

class LoginService: LoginServiceProtocol {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func login(username: String, password: String) async throws -> User {
        let requestBody = [
            "username": username,
            "password": password
        ]

        let bodyData = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        let response: APIResponse<User> = try await networkManager.request(
            endpoint: "/login",
            method: .POST,
            body: bodyData
        )

        guard response.success else {
            throw NetworkError.serverError(0)
        }

        guard let user = response.data else {
            throw NetworkError.decodingError
        }

        return user
    }
}
