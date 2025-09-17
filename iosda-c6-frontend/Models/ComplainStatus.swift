//
//  ComplainStatus.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 08/09/25.
//

import SwiftUI

enum ComplaintStatus: String {
    case underReviewbByBSC = "under review by bsc"
    case underReviewByBI = "under review by bi"
    case waitingKeyHandover = "waiting key handover"
    case inProgress = "in progress"
    case resolved = "resolved"
    case rejected = "rejected"
    case closed = "closed"
    case open = "open"
    case assignToVendor = "assign to vendor"
    case unknown = "unknown"
    
    init(raw: String?) {
        guard let raw = raw?.lowercased() else {
            self = .unknown
            return
        }
        switch raw {
        case "open": self = .open
        case "under review by bsc": self = .underReviewbByBSC
        case "under review by bi": self = .underReviewByBI
        case "waiting key handover": self = .waitingKeyHandover
        case "in progress": self = .inProgress
        case "resolved": self = .resolved
        case "rejected": self = .rejected
        case "closed": self = .closed
        case "assign to vendor": self = .assignToVendor
        default: self = .unknown
        }
    }

    
    var color: Color {
        switch self {
        case .open: return .red
        case .underReviewbByBSC: return .orange
        case .underReviewByBI: return .orange
        case .waitingKeyHandover: return .brown
        case .inProgress: return .blue
        case .resolved: return .green
        case .rejected: return .red
        case .unknown: return .gray
        case .assignToVendor: return .purple
        case .closed:
            return .gray
        }
    }
    
    var displayName: String {
        switch self {
        case .open: return "Open"
        case .underReviewbByBSC: return "Under Review By BSC"
        case .underReviewByBI: return "Under Review By BI"
        case .waitingKeyHandover: return "Waiting Key Handover"
        case .inProgress: return "In Progress"
        case .resolved: return "Resolved"
        case .rejected: return "Rejected"
        case .unknown: return "Unknown"
        case .assignToVendor: return "Assign To Vendor"
        case .closed:
            return "Closed"
        }
    }
    
    var isLockingStatus: Bool {
        switch self {
        case .waitingKeyHandover, .underReviewByBI, .inProgress, .assignToVendor:
            return true
        default:
            return false
        }
    }

}

