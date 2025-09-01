import Foundation

struct ProgressLog: Identifiable, Codable {
    let id: Int?
    let userId: Int?
    let attachmentId: Int?
    let title: String?
    let description: String?
    let timestamp: Date?
    
    // Navigation properties
    //var user: User?
    var files: [File]?
    var progressFiles: [ProgressFile]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case userId = "user_uuid"
        case attachmentId = "attachment_uuid"
        case title
        case description
        case timestamp
    }
}
