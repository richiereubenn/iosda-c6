//
//  UnitService2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 12/09/25.
//

import Foundation

protocol UnitServiceProtocol2 {
    func getAllUnits() async throws -> [Unit2]
    func getUnitsByResidentId(residentId: String) async throws -> [Unit2]
    func getUnitsByBSCId() async throws -> [Unit2]
    func getUnitsByBIId() async throws -> [Unit2]
    func createUnit(name: String, resident_id: String, bsc_id: String?, bi_id: String?, unitCode_id: String, unit_number: String) async throws -> Unit2
}

class UnitService2: UnitServiceProtocol2 {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllUnits() async throws -> [Unit2] {
        let response: APIResponse<[Unit2]> = try await networkManager.request(endpoint: "/property/v1/units")
        
        guard response.success else {
            throw NetworkError.serverError(0)
        }
        
        guard let units = response.data else {
            throw NetworkError.decodingError
        }
        
        return units
    }
    
    func getUnitsByResidentId(residentId: String) async throws -> [Unit2] {
        guard let residentId = networkManager.getUserIdFromToken() else {
            throw NetworkError.noData
        }
        let endpoint = "/property/v1/units?resident_id=\(residentId)"
        let response: APIResponse<[Unit2]> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        return response.data ?? []
    }
    
    func getUnitsByBSCId() async throws -> [Unit2] {
        guard let bscId = networkManager.getUserIdFromToken() else {
            throw NetworkError.noData
        }
        let endpoint = "/property/v1/units?bsc_id=\(bscId)"
        let response: APIResponse<[Unit2]> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        return response.data ?? []
    }
    
    func getUnitsByBIId() async throws -> [Unit2] {
        guard let biId = networkManager.getUserIdFromToken() else {
            throw NetworkError.noData
        }
        let endpoint = "/property/v1/units?bi_id=\(biId)"
        let response: APIResponse<[Unit2]> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        return response.data ?? []
    }
    
    func createUnit(
        name: String,
        resident_id: String,
        bsc_id: String?,
        bi_id: String?,
        unitCode_id: String,
        unit_number: String
    ) async throws -> Unit2 {
        let endpoint = "/property/v1/units"
        
        // Use Codable struct instead of dictionary for better type safety
        let unitRequest = CreateUnitRequest2(
            name: name,
            resident_id: resident_id,
            bsc_id: bsc_id,
            bi_id: bi_id,
            unit_code_id: unitCode_id,
            unit_number: unit_number
        )
        
        let body = try JSONEncoder().encode(unitRequest)
        
        let response: APIResponse<Unit2> = try await networkManager.request(
            endpoint: endpoint,
            method: .POST,
            body: body
        )
        
        guard response.success, let unit = response.data else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        
        return unit
    }
    
//    func getClaimedUnits() async throws -> [Unit2] {
//        let units = try await getUnitsByResidentId()
//        return units.filter { unit in
//            guard let bscId = unit.bscId else { return false }
//            return !bscId.isEmpty
//        }
//    }
//    
//    func getWaitingUnits() async throws -> [Unit2] {
//        let units = try await getUnitsByResidentId()
//        return units.filter { unit in
//            guard let bscId = unit.bscId else { return true }
//            return bscId.isEmpty
//        }
//    }
}

