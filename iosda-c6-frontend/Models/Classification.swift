//
//  Classification.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 31/08/25.
//


struct Classification: Identifiable, Codable {
    let id: Int?
    let name: String
    let workDetail: String?
    let workDuration: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case workDetail = "work_detail"
        case workDuration = "work_duration"
    }
}
