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

