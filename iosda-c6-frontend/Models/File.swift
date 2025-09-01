
struct File: Identifiable, Codable {
    let id: Int?
    let name: String?
    let path: String?
    let mimeType: String?
    let otherAttributes: String? // JSON field
    
    // Navigation properties
    var progressFiles: [ProgressFile]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case path
        case mimeType = "mime_type"
        case otherAttributes = "other_attributes"
    }
}
