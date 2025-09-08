//
//  ComplaintService2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 08/09/25.
//

import Foundation

protocol ComplaintServiceProtocol2 {
    func getAllComplaints() async throws -> [Complaint2]
    func getComplaintsByUnitId(_ unitId: String) async throws -> [Complaint2]
    func getComplaintById(_ id: String) async throws -> Complaint2 
}

class ComplaintService2: ComplaintServiceProtocol2 {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllComplaints() async throws -> [Complaint2] {
        let response: APIResponse<[Complaint2]> = try await networkManager.request(endpoint: "/complaint/v1/complaints")
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        return response.data ?? []
    }
    
    func getComplaintsByUnitId(_ unitId: String) async throws -> [Complaint2] {
        let endpoint = "/complaint/v1/complaints?unit_id=\(unitId)"
        let response: APIResponse<[Complaint2]> = try await networkManager.request(endpoint: endpoint)
        
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        return response.data ?? []
    }
    
    func getComplaintById(_ id: String) async throws -> Complaint2 {
        let endpoint = "/complaint/v1/complaints/\(id)"
        let response: APIResponse<Complaint2> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        guard let complaint = response.data else {
            throw NetworkError.noData
        }
        return complaint
    }
}
