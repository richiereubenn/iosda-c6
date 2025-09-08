import Foundation

struct UserUnit: Identifiable, Codable {
    let id: String?
    let userId: String?
    let unitId: String?
    let ownershipType: String?
    
    // Navigation properties
//    var user: User?
    var unit: Unit?
    
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case userId = "user_uuid"
        case unitId = "unit_uuid"
        case ownershipType = "ownership_type"
    }
}
