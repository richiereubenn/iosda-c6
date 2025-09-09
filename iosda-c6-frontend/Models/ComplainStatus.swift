//
//  ComplainStatus.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 08/09/25.
//

import SwiftUI

enum ComplaintStatus: String {
    case open = "open"
    case underReview = "under review"
    case waitingKeyHandover = "waiting key handover"
    case inProgress = "in progress"
    case resolved = "resolved"
    case rejected = "rejected"
    case closed = "closed"
    case unknown = "unknown"
    
    init(raw: String?) {
        guard let raw = raw?.lowercased() else {
            self = .unknown
            return
        }
        switch raw {
        case "open": self = .open
        case "under review": self = .underReview
        case "waiting key handover": self = .waitingKeyHandover
        case "in progress": self = .inProgress
        case "resolved": self = .resolved
        case "rejected": self = .rejected
        case "closed": self = .closed
        default: self = .unknown
        }
    }

    
    var color: Color {
        switch self {
        case .open: return .red
        case .underReview: return .yellow
        case .waitingKeyHandover: return .orange
        case .inProgress: return .blue
        case .resolved: return .green
        case .rejected: return .gray
        case .unknown: return .gray
        case .closed:
            return .gray
        }
    }
    
    var displayName: String {
        switch self {
        case .open: return "Open"
        case .underReview: return "Under Review"
        case .waitingKeyHandover: return "Waiting Key Handover"
        case .inProgress: return "In Progress"
        case .resolved: return "Resolved"
        case .rejected: return "Rejected"
        case .unknown: return "Unknown"
        case .closed:
            return "Closed"
        }
    }
}
