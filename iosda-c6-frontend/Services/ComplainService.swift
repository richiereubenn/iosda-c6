//
//  ComplainService.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import Foundation

protocol ComplaintServiceProtocol {
    func getAllComplaints() async throws -> [Complaint]
}

class ComplaintService: ComplaintServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllComplaints() async throws -> [Complaint] {
        let response: APIResponse<[Complaint]> = try await networkManager.request(
            endpoint: "/complaints"
        )
        
        guard response.isSuccess else {
            throw NetworkError.serverError(0)
        }
        
        return response.data
    }
}

