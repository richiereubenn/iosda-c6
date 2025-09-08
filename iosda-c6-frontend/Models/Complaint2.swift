//
//  Complaint 2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 08/09/25.
//

import Foundation
import SwiftUICore

struct Complaint2: Identifiable, Codable {
    let id: String
    let unitId: String?
    let userId: String?
    let statusId: String?
    let classificationId: String?
    let title: String
    let description: String
    let openTimestamp: Date?
    let closeTimestamp: Date?
    let keyHandoverDate: Date?
    let deadlineDate: String?
    let latitude: String?
    let longitude: String?
    let handoverMethod: String?
    let workDetail: String?
    let workDuration: String?
    let createdAt: Date?
    let updatedAt: Date?
    let statusName: String?
    let classificationName: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case unitId = "unit_id"
        case userId = "user_id"
        case statusId = "status_id"
        case classificationId = "classification_id"
        case title
        case description
        case openTimestamp = "open_timestamp"
        case closeTimestamp = "close_timestamp"
        case keyHandoverDate = "key_handover_date"
        case deadlineDate = "deadline_date"
        case latitude
        case longitude
        case handoverMethod = "handover_method"
        case workDetail = "work_detail"
        case workDuration = "work_duration"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case statusName = "status_name"
        case classificationName = "classification_name"
    }
}
