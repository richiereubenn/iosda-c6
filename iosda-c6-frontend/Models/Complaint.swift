import Foundation

struct Complaint: Identifiable, Codable {
    let id: Int?
    let unitId: Int?
    let statusId: Int?
    let progressId: Int?
    let classificationId: Int?
    let title: String
    let description: String
    let openTimestamp: Date?
    let closeTimestamp: Date?
    let keyHandoverDate: Date?
    let deadlineDate: Date?
    let latitude: Double?
    let longitude: Double?
    
    // Navigation properties
    var unit: Unit?
    var status: Status?
    var classification: Classification?
//    var progressLogs: [ProgressLog]?
    
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
    }
}

