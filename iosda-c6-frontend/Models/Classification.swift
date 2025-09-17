//
//  Classification.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 31/08/25.
//


struct Classification: Identifiable, Codable {
    let id: String?
    let name: String
    let workDetail: String?
    let workDuration: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case workDetail = "work_detail"
        case workDuration = "work_duration"
    }
}
