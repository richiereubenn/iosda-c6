import Foundation

struct Unit: Identifiable, Codable {
    let id: Int?
    let name: String
    let bscUuid: String?
    let biUuid: String?
    let contractorUuid: String?
    let keyUuid: String?
    let project: String?
    let area: String?
    let block: String?
    let unitNumber: String?
    let handoverDate: Date?
    let renovationPermit: Bool?
    let isApproved: Bool?
    
//    // Navigation properties
//    var userUnits: [UserUnit]?
//    var keyLogs: [KeyLog]?
//    var complaints: [Complaint]?
//    var progressLogs: [ProgressLog]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case bscUuid = "doc_ic_uuid"
        case biUuid = "bl_ic_uuid"
        case contractorUuid = "contractor_uuid"
        case keyUuid = "key_uuid"
        case project
        case area
        case block
        case unitNumber = "unit_number"
        case handoverDate = "handover_date"
        case renovationPermit = "renovation_permit"
        case isApproved = "is_approved"
    }
}
