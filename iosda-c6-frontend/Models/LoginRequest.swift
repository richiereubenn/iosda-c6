//
//  LoginRequest.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 09/09/25.
//


struct LoginRequest: Codable {
    let identifier: String
    let password: String
}

struct LoginData: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: String
    let user: User

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case user
    }
}


struct LoginResponse: Codable {
    let success: Bool
    let code: Int
    let message: String
    let data: LoginData
}
