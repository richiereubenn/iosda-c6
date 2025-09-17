struct User: Identifiable, Codable {
    let id: String?
    let roleId: String?
    let name: String?         // <== Changed to optional
    let phone: String?
    let email: String?        // <== Changed to optional
    let username: String?     // <== Changed to optional
    let password: String?
    let acceptTosPrivacy: Bool?
    let otherAttribute: OtherAttribute?
    
    // Navigation properties
    var role: Role?
    var complaints: [Complaint]?

    private enum CodingKeys: String, CodingKey {
        case id
        case roleId = "role_uuid"
        case name
        case phone
        case email
        case username
        case password
        case acceptTosPrivacy = "accept_tos_pp"
        case otherAttribute = "other_attribute"
        case role
        case complaints
    }
}

struct OtherAttribute: Codable {
    var department: String?
    var location: String?
}

struct UserDetailResponse: Codable {
    let success: Bool
    let code: Int
    let message: String
    let data: User
}
