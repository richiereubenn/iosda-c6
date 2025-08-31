//
//  ComplainService.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import Foundation

protocol ComplainServiceProtocol {
    func getAllComplaints() async throws -> [ComplaintModel]
}

class ComplainService: ComplainServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllComplaints() async throws -> [ComplaintModel] {
        let response: APIResponse<[ComplaintModel]> = try await networkManager.request(
            endpoint: "/complaints"
        )
        
        guard response.isSuccess else {
            throw NetworkError.serverError(0)
        }
        
        guard let complaints = response.data else {
               throw NetworkError.decodingError // or custom .missingData error
           }
        
        return complaints
    }
}

