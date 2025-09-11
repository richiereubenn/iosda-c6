//
//  User.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 08/09/25.
//



struct User: Identifiable, Codable {
    let id: String?
    let roleId: String?
    let name: String
    let phone: String?
    let email: String?
    let username: String
    let password: String
    let acceptTosPrivacy: Bool
    
    // Navigation properties
    var role: Role?
    var complaints: [Complaint]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case roleId = "role_uuid"
        case name
        case phone
        case email
        case username
        case password
        case acceptTosPrivacy = "accept_tos_pp"
        case role
    }
    
    init(id: String? = nil, roleId: String? = nil, name: String, phone: String?, email: String?, username: String, password: String, acceptTosPrivacy: Bool) {
        self.id = id
        self.roleId = roleId
        self.name = name
        self.phone = phone
        self.email = email
        self.username = username
        self.password = password
        self.acceptTosPrivacy = acceptTosPrivacy
    }

}
