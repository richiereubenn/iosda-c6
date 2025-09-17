//
//  KeyFile.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 14/09/25.
//

import Foundation

struct KeyFile: Codable, Identifiable {
    let id: String
    let name: String
    let path: String
    let url: String
    let mimeType: String?

    enum CodingKeys: String, CodingKey {
        case id, name, path, url
        case mimeType = "mime_type"
    }
}
