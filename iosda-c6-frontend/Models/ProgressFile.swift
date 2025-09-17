import Foundation

struct ProgressFile: Identifiable, Codable {
    let id: String?
    let progressId: String?
    let fileId: String?
    
    // Navigation properties
    var progress: ProgressLog?
    var file: File?
    
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case progressId = "progress_uuid"
        case fileId = "file_uuid"
    }
}
