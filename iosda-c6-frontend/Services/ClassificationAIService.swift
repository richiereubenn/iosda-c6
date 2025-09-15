//
//  ClassificationAIService.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 15/09/25.
//

import Foundation

protocol ClassificationAIServiceProtocol {
    func getClassification(request: ClassificationRequest) async throws -> ClassificationAI
}

class ClassificationAIService: ClassificationAIServiceProtocol{
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getClassification(request: ClassificationRequest) async throws -> ClassificationAI {
        let endpoint = "/ai/classify"

        let bodyData = try JSONEncoder().encode(request)
        
        let response: APIResponse<ClassificationAI> = try await networkManager.request(
            endpoint: endpoint,
            method: .POST,
            body: bodyData
        )
        
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        
        guard let classification = response.data else {
            throw NetworkError.noData
        }
        
        return classification
    }
}
