import Foundation
import SwiftUI

struct Status: Identifiable, Codable {
    let id: String?
    let name: String
    
    enum ComplaintStatusID: String, CaseIterable {
        case open = "1"
        case underReview = "2"
        case waitingKey = "3"
        case inProgress = "4"
        case resolved = "5"
        case rejected = "6"
        
        var apiName: String {
            switch self {
            case .open: return "open"
            case .underReview: return "under_review"
            case .waitingKey: return "waiting_key"
            case .inProgress: return "in_progress"
            case .resolved: return "resolved"
            case .rejected: return "rejected"
            }
        }
    }
    
    var complaintStatusID: ComplaintStatusID? {
           guard let id = id else { return nil }
           return ComplaintStatusID(rawValue: id)
       }
    
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
    }
}

extension Status.ComplaintStatusID {
    var color: Color {
        switch self {
        case .open:
            return .red
        case .underReview:
            return .yellow
        case .waitingKey:
            return .orange
        case .inProgress:
            return .blue
        case .resolved:
            return .green
        case .rejected:
            return .gray
        }
    }
    
    var displayName: String {
        switch self {
        case .open: return "Open"
        case .underReview: return "Under Review"
        case .waitingKey: return "Waiting Key"
        case .inProgress: return "In Progress"
        case .resolved: return "Resolved"
        case .rejected: return "Rejected"
        }
    }
}
