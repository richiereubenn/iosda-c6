//
//  HandoverMethod.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 13/09/25.
//


import Foundation

enum HandoverMethod: String, Codable {
    case inHouse = "In House"
    case bringToMO = "Bring to MO"
    
    var displayName: String {
        switch self {
        case .inHouse: return "In House"
        case .bringToMO: return "Bring to MO"
        }
    }
    
    init?(displayName: String) {
        switch displayName {
        case "In House":
            self = .inHouse
        case "Bring to MO":
            self = .bringToMO
        default:
            return nil
        }
    }
}
