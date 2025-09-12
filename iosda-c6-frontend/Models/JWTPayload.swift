//
//  JWTPayload.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 13/09/25.
//

import Foundation

struct JWTPayload: Codable {
    let user_id: String?
    let name: String?
    let email: String?
    let roles: [String]?
    let exp: Int?
}
