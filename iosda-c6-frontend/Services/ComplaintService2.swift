//
//  ComplaintService2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 08/09/25.
//

import Foundation

protocol ComplaintServiceProtocol2 {
    func fetchComplaints() async throws -> [Complaint2]
}

class ComplaintService2: ComplaintServiceProtocol2 {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func fetchComplaints() async throws -> [Complaint2] {
        let response: APIResponse<[Complaint2]> = try await networkManager.request(endpoint: "/complaint/v1/complaints")
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        return response.data ?? []
    }
    
}
