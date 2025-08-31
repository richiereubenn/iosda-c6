import Foundation

protocol ComplaintServiceProtocol {
    func fetchComplaints() async throws -> [Complaint]
    func createComplaint(_ request: CreateComplaintRequest) async throws -> Complaint
    func updateComplaintStatus(id: Int, statusId: Int) async throws -> Complaint
    func deleteComplaint(id: Int) async throws
}

class ComplaintService: ComplaintServiceProtocol {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func fetchComplaints() async throws -> [Complaint] {
        let response: APIResponse<[Complaint]> = try await networkManager.request(endpoint: "/complaints")

        guard response.success else {
            throw NetworkError.serverError(0)
        }

        guard let complaints = response.data else {
            throw NetworkError.decodingError
        }

        return complaints
    }

    func createComplaint(_ request: CreateComplaintRequest) async throws -> Complaint {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let bodyData = try encoder.encode(request)

        let response: APIResponse<Complaint> = try await networkManager.request(
            endpoint: "/complaints",
            method: .POST,
            body: bodyData
        )

        guard response.success else {
            throw NetworkError.serverError(0)
        }

        guard let complaint = response.data else {
            throw NetworkError.decodingError
        }

        return complaint
    }
    
    
    
    func updateComplaintStatus(id: Int, statusId: Int) async throws -> Complaint {
        let request = ["status_uuid": statusId]
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(request)
        
        let response: APIResponse<Complaint> = try await networkManager.request(
            endpoint: "/complaints/\(id)",
            method: .PATCH,
            body: bodyData
        )
        
        guard response.success else {
            throw NetworkError.serverError(0)
        }
        
        guard let complaint = response.data else {
            throw NetworkError.decodingError
        }
        
        return complaint
    }

    func deleteComplaint(id: Int) async throws {
        try await networkManager.requestEmpty(endpoint: "/complaints/\(id)", method: .DELETE)
    }
}
