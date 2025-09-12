//
//  AreaService.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 12/09/25.
//

import Foundation

protocol AreaServiceProtocol {
    func getAllAreas() async throws -> [Area]
    func getAreaById(_ id: String) async throws -> Area
}

class AreaService: AreaServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllAreas() async throws -> [Area] {
        let response: APIResponse<[Area]> = try await networkManager.request(endpoint: "/property/v1/areas")
        
        guard response.success else {
            throw NetworkError.serverError(0)
        }
        
        guard let areas = response.data else {
            throw NetworkError.decodingError
        }
        
        return areas
    }
    
    func getAreaById(_ id: String) async throws -> Area {
        let endpoint = "/property/v1/areas/\(id)"
        let response: APIResponse<Area> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        guard let area = response.data else {
            throw NetworkError.noData
        }
        return area
    }
}
