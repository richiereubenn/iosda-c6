//
//  Area.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 12/09/25.
//

import Foundation

struct Area: Codable, Identifiable {
    let id: String
    let projectId: String
    let name: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case projectId = "project_id"
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
