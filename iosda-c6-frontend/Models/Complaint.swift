import Foundation

struct Complaint: Identifiable, Codable {
    let id: String?
    let unitId: String?
    let statusId: String?
    let progressId: String?
    let classificationId: String?
    let title: String
    let description: String
    let openTimestamp: Date?
    let closeTimestamp: Date?
    let keyHandoverDate: Date?
    let deadlineDate: Date?
    let latitude: Double?
    let longitude: Double?
    let handoverMethod: HandoverMethod?
    
    // Navigation properties
    var unit: Unit?
    var status: Status?
    var classification: Classification?
//    var progressLogs: [ProgressLog]?
    
    enum HandoverMethod: String, Codable {
        case inHouse = "in_house"
        case bringToMO = "bring_to_mo"
    }

    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case unitId = "unit_uuid"
        case statusId = "status_uuid"
        case progressId = "progress_uuid"
        case classificationId = "classification_uuid"
        case title
        case description
        case openTimestamp = "open_timestamp"
        case closeTimestamp = "close_timestamp"
        case keyHandoverDate = "key_handover_date"
        case deadlineDate = "deadline_date"
        case latitude
        case longitude
        case handoverMethod = "handover_method"
    }
}

extension Complaint.HandoverMethod {
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
