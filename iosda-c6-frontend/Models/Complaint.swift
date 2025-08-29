//
//  Complaint.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import Foundation

struct Complaint: Identifiable, Codable {
    let id: Int?
    let title: String
    let description: String
    let category: String
    let status: ComplaintStatus
    let createdAt: Date?
    let updatedAt: Date?
    
    enum ComplaintStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case inProgress = "in_progress"
        case resolved = "resolved"
        case rejected = "rejected"
        
        var displayName: String {
            switch self {
            case .pending: return "Menunggu"
            case .inProgress: return "Diproses"
            case .resolved: return "Selesai"
            case .rejected: return "Ditolak"
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension Complaint {
    static let sampleData = Complaint(
        id: 1,
        title: "Jalan Rusak",
        description: "Jalan di depan rumah berlubang besar",
        category: "Infrastruktur",
        status: .pending,
        createdAt: Date(),
        updatedAt: Date()
    )
}
