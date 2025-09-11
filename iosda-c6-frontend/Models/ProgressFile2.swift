//
//  ProgressFile2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 09/09/25.
//

import Foundation
import SwiftUICore


struct ProgressFile2: Identifiable, Codable {
    let id: String?
    let name: String?
    let path: String?
    let url: String?
    let mimeType: String?
//    let createdAt: Date?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case path
        case url
        case mimeType = "mime_type"
//        case createdAt = "created_at"
    }
}
