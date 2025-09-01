
struct ProgressFile: Identifiable, Codable {
    let id: Int?
    let progressId: Int?
    let fileId: Int?
    
    // Navigation properties
    var progress: ProgressLog?
    var file: File?
    
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case progressId = "progress_uuid"
        case fileId = "file_uuid"
    }
}
