//
//  ProgressLog2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 09/09/25.
//

import Foundation

struct ProgressLog2: Identifiable, Codable {
    let id: String?
    let complaintId: String?
    let userId: String?
    let title: String?
    let description: String?
    let timestamp: Date?
    let createdAt: Date?
    let updatedAt: Date?
    var files: [ProgressFile2]?

    private enum CodingKeys: String, CodingKey {
        case id
        case complaintId = "complaint_id"
        case userId = "user_id"
        case title
        case description
        case timestamp
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case files
    }
}
