//
//  Role.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 08/09/25.
//


struct Role: Identifiable, Codable {
    let id: Int?
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
    }
}