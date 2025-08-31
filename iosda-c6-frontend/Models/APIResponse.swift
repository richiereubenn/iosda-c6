//
//  APIResponse.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import Foundation

struct APIResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
    let success: Bool
    
    var isSuccess: Bool {
        return success
    }
    
    var errorMessage: String {
        return message ?? "Terjadi kesalahan yang tidak diketahui"
    }
}

extension APIResponse {
    static func successResponse(message: String = "Berhasil") -> APIResponse<EmptyData> {
        return APIResponse<EmptyData>(
            data: EmptyData(),
            message: message,
            success: true
        )
    }
    
    static func errorResponse(message: String) -> APIResponse<EmptyData> {
        return APIResponse<EmptyData>(
            data: EmptyData(),
            message: message,
            success: false
        )
    }
}

struct EmptyData: Codable {
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
    let unitId: Int
    let title: String
    let description: String
    let classificationId: Int?
    let keyHandoverDate: Date?
    let latitude: Double?
    let longitude: Double?
    
    private enum CodingKeys: String, CodingKey {
        case unitId = "unit_uuid"
        case title
        case description
        case classificationId = "classification_uuid"
        case keyHandoverDate = "key_handover_date"
        case latitude
        case longitude
    }
}

