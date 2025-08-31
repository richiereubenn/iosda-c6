import Foundation


struct KeyLog: Identifiable, Codable {
    let id: Int?
    let position: String?
    let timestamp: Date?
    
    enum KeyStatus: String, Codable, CaseIterable {
        case resident = "resident"
        case bsc = "bsc"
        case bi = "bi"
        
        var displayName: String {
            switch self {
            case .resident: return "Resident"
            case .bsc: return "BSC"
            case .bi: return "BI"
            }
        }
    }
        
    private enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case position
        case timestamp
    }
}
