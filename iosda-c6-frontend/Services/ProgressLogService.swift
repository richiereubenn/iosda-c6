//
//  ProgressLogService.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 09/09/25.
//

import Foundation

protocol ProgressLogServiceProtocol {
    func getAllProgress(complaintId: String) async throws -> [ProgressLog2]
    func getFirstProgress(complaintId: String) async throws -> ProgressLog2?
}

class ProgressLogService: ProgressLogServiceProtocol {
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllProgress(complaintId: String) async throws -> [ProgressLog2] {
        let endpoint = "/complaint/v1/complaints/\(complaintId)/progress"
        
        let response: APIResponse<[ProgressLog2]> = try await networkManager.request(endpoint: endpoint)
        
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        
        return response.data ?? []
    }
    
    func getFirstProgress(complaintId: String) async throws -> ProgressLog2? {
        let logs = try await getAllProgress(complaintId: complaintId)
        return logs.first
    }
}


