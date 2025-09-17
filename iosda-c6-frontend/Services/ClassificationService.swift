//
//  ClassificationService.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 11/09/25.
//

import Foundation

protocol ClassificationServiceProtocol {
    func fetchClassification() async throws -> [Classification]
    func getClassificationById(_ id: String) async throws -> Classification
}

class ClassificationService: ClassificationServiceProtocol{
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func fetchClassification() async throws -> [Classification] {
        let response: APIResponse<[Classification]> = try await networkManager.request(endpoint: "/complaint/v1/classifications?page=1&limit=100")

        guard response.success else {
            throw NetworkError.serverError(0)
        }

        guard let classifications = response.data else {
            throw NetworkError.decodingError
        }

        return classifications
    }
    
    func getClassificationById(_ id: String) async throws -> Classification {
        let endpoint = "/complaint/v1/classifications/\(id)"
        let response: APIResponse<Classification> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        guard let classification = response.data else {
            throw NetworkError.noData
        }
        return classification
    }
    
}
