import Foundation

struct KeyLog: Identifiable, Codable {
    let id: String
    let unitId: String?
    let userId: String?
    let detail: String?
    let timestamp: Date?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let files: [KeyFile]

    enum CodingKeys: String, CodingKey {
        case id
        case unitId = "unit_id"
        case userId = "user_id"
        case detail
        case timestamp
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case files
    }
}
