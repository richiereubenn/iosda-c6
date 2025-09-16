//
//  APIResponse.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import Foundation

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let code: Int?
    let message: String?
    let data: T?
    let errors: [String: String]?
    let meta: MetaData?
    
    var isSuccess: Bool {
        return success
    }
    
    var errorMessage: String {
        return message ?? "Terjadi kesalahan yang tidak diketahui"
    }
}

struct MetaData: Codable {
    let pagination: Pagination?
    let requestId: String?
    let timestamp: String?
    let processingTimeMs: Int?
    let startTime: Int?
    
    private enum CodingKeys: String, CodingKey {
        case pagination
        case requestId = "request_id"
        case timestamp
        case processingTimeMs = "processing_time_ms"
        case startTime = "start_time"
    }
}

struct Pagination: Codable {
    let totalItems: Int
    let perPage: Int
    let currentPage: Int
    let totalPages: Int
    
    private enum CodingKeys: String, CodingKey {
        case totalItems = "total_items"
        case perPage = "per_page"
        case currentPage = "current_page"
        case totalPages = "total_pages"
    }
}

struct CreateUnitRequest: Codable {
    let name: String
    let project: String?
    let area: String?
    let block: String?
    let unitNumber: String?
    let handoverDate: Date?
    let renovationPermit: Bool?
    let ownershipType: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case project
        case area
        case block
        case unitNumber = "unit_number"
        case handoverDate = "handover_date"
        case renovationPermit = "renovation_permit"
        case ownershipType = "ownership_type"
    }
}

struct CreateUnitRequest2: Codable {
    let name: String
    let resident_id: String
    let bsc_id: String?
    let bi_id: String?
    let unit_code_id: String
    let unit_number: String
    let handover_date: String     // ISO8601 string
    let renovation_permit: Bool
}

struct CreateComplaintRequest: Codable {
    let unitId: String
    let title: String
    let description: String
    let classificationId: String?
    let keyHandoverDate: Date?
    let latitude: Double?
    let longitude: Double?
    let handoverMethod: String?
    
    private enum CodingKeys: String, CodingKey {
        case unitId = "unit_uuid"
        case title
        case description
        case classificationId = "classification_uuid"
        case keyHandoverDate = "key_handover_date"
        case latitude
        case longitude
        case handoverMethod = "handover_method"
    }
}

struct UserDetailData: Codable {
    let user: User
}

struct ClassificationRequest: Codable {
    let complaintDetail: String

    enum CodingKeys: String, CodingKey {
        case complaintDetail = "complaint_detail"
    }
}

struct CreateComplaintRequest2: Codable {
    let unitId: String
    let userId: String
    let statusId: String
    let classificationId: String?
    let title: String
    let description: String
    let latitude: Double?
    let longitude: Double?
    let handoverMethod: HandoverMethod
    let keyHandoverDate: Date?        // Added
    let keyHandoverNote: String?      // Added
    
    
    enum CodingKeys: String, CodingKey {
        case unitId = "unit_id"
        case userId = "user_id"
        case statusId = "status_id"
        case classificationId = "classification_id"
        case title
        case description
        case latitude
        case longitude
        case handoverMethod = "handover_method"
        case keyHandoverDate = "key_handover_date"
        case keyHandoverNote = "key_handover_note"
    }
}

struct UpdateUnitRequest: Codable {
    let name: String
    let unit_code_id: String
    let unit_number: String
    let resident_id: String
    let bsc_id: String?
    let bi_id: String?
    let handover_date: String?
    let key_handover_date: String?
    let key_handover_note: String?
}
