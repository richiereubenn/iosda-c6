//
//  Unit2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 12/09/25.
//

import Foundation

struct Unit2: Codable, Identifiable {
    let id: String
    let unitCodeId: String?
    let contractorId: String?
    let name: String?
    let unitNumber: String?
    let handoverDate: Date?
    let box: Int?               
    let renovationPermit: Bool?
    let keyHandoverDate: Date?
    let keyHandoverNote: String?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let residentId: String?
    let bscId: String?
    let biId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case unitCodeId = "unit_code_id"
        case contractorId = "contractor_id"
        case name
        case unitNumber = "unit_number"
        case handoverDate = "handover_date"
        case box
        case renovationPermit = "renovation_permit"
        case keyHandoverDate = "key_handover_date"
        case keyHandoverNote = "key_handover_note"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case residentId = "resident_id"
        case bscId = "bsc_id"
        case biId = "bi_id"
    }
}

