import Foundation

struct ProgressLog: Identifiable, Codable {
    let id: String?
    let userId: String?
    let attachmentId: String?
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

extension ProgressLog {
    var isCompleted: Bool {
        // You can customize this logic based on your business rules
        // For example, check if description contains certain keywords
        // or if there's a specific status field
        return description?.contains("selesai") == true ||
               description?.contains("diterima") == true ||
               title?.contains("masuk") == true
    }
}
