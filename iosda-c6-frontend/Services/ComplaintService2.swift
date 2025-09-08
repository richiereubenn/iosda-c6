//
//  ComplaintService2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 08/09/25.
//

import Foundation

protocol ComplaintServiceProtocol2 {
    func fetchAllComplaints() async throws -> [Complaint2]
    func fetchComplaintsByUnitId(_ unitId: String) async throws -> [Complaint2] // <-- baru
}

class ComplaintService2: ComplaintServiceProtocol2 {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func fetchAllComplaints() async throws -> [Complaint2] {
        let response: APIResponse<[Complaint2]> = try await networkManager.request(endpoint: "/complaint/v1/complaints")
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        return response.data ?? []
    }
    
    func fetchComplaintsByUnitId(_ unitId: String) async throws -> [Complaint2] {
        let endpoint = "/complaint/v1/complaints?unit_id=\(unitId)"
        let response: APIResponse<[Complaint2]> = try await networkManager.request(endpoint: endpoint)
        
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        return response.data ?? []
    }
}
