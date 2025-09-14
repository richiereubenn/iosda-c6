import Foundation

struct KeyLog: Identifiable, Codable {
    let id: UUID
    let unitID: UUID?
    let userID: UUID?
    let detail: String?
    let timestamp: Date?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
    let files: [KeyFile]

    enum CodingKeys: String, CodingKey {
        case id
        case unitID = "unit_id"
        case userID = "user_id"
        case detail
        case timestamp
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case files
    }
}
