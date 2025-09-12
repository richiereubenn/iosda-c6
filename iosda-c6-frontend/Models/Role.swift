//
//  Role.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 08/09/25.
//

struct Role: Identifiable, Codable {
    let id: String?
    let name: String
    let description: String?
}

struct MeResponse: Codable {
    let user: User
    let roles: [Role]
}
