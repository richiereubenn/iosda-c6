//
//  UnitCodeService.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 12/09/25.
//

import Foundation

protocol UnitCodeServiceProtocol {
    func getAllUnitCodes() async throws -> [UnitCode]
    func getUnitCodeById(_ id: String) async throws -> UnitCode
}

class UnitCodeService: UnitCodeServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllUnitCodes() async throws -> [UnitCode] {
        let response: APIResponse<[UnitCode]> = try await networkManager.request(endpoint: "/property/v1/unit-codes")
        
        guard response.success else {
            throw NetworkError.serverError(0)
        }
        
        guard let unitCodes = response.data else {
            throw NetworkError.decodingError
        }
        
        return unitCodes
    }
    
    func getUnitCodeById(_ id: String) async throws -> UnitCode {
        let endpoint = "/property/v1/unit-codes/\(id)"
        let response: APIResponse<UnitCode> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        guard let unitCode = response.data else {
            throw NetworkError.noData
        }
        return unitCode
    }
}
