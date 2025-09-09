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

struct UserData: Codable {
    let user: User
}

