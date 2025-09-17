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
    func getUnitById(_ id: String) async throws -> Unit2
    func createUnit(name: String, resident_id: String, bsc_id: String?, bi_id: String?, unitCode_id: String, unit_number: String, handover_date: Date, renovation_permit: Bool) async throws -> Unit2

    func updateUnit(unitId: String, bscId: String) async throws -> Unit2

    func updateUnitKey(_ unit: Unit2, keyDate: Date, note: String) async throws -> Unit2
    func updateUnitKeyOptional(_ unit: Unit2, keyDate: Date?, note: String?) async throws -> Unit2

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
    

    func getUnitById(_ id: String) async throws -> Unit2 {
        let endpoint = "/property/v1/units/\(id)"
        let response: APIResponse<Unit2> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        guard let unit = response.data else {
            throw NetworkError.noData
        }
        return unit
    }
    
    func createUnit(
        name: String,
        resident_id: String,
        bsc_id: String?,
        bi_id: String?,
        unitCode_id: String,
        unit_number: String,
        handover_date: Date = Date(),
        renovation_permit: Bool = true
    ) async throws -> Unit2 {
        let endpoint = "/property/v1/units"
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let handoverDateString = formatter.string(from: handover_date)
        
        let unitRequest = CreateUnitRequest2(
            name: name,
            resident_id: resident_id,
            bsc_id: bsc_id,
            bi_id: bi_id,
            unit_code_id: unitCode_id,
            unit_number: unit_number,
            handover_date: handoverDateString,
            renovation_permit: renovation_permit
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


    func updateUnit(unitId: String, bscId: String) async throws -> Unit2 {
            let endpoint = "/property/v1/units/\(unitId)"
            
            let bodyDict: [String: Any] = [
                "bsc_id": bscId
            ]
            let bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
            
            let response: APIResponse<Unit2> = try await networkManager.request(
                endpoint: endpoint,
                method: .PUT,
                body: bodyData
            )
            
            guard response.success else {
                throw NetworkError.serverError(response.code ?? 0)
            }
            
            guard let updatedUnit = response.data else {
                throw NetworkError.noData
            }
            
            return updatedUnit
        }
    

    func updateUnitKey(_ unit: Unit2, keyDate: Date, note: String) async throws -> Unit2 {
        let endpoint = "/property/v1/units/\(unit.id)"
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        // Format the date to the proper format for the API
        let keyHandoverDateString = formatter.string(from: keyDate)
        

        let updateRequest = UpdateUnitRequest(
            name: unit.name ?? "",
            unit_code_id: unit.unitCodeId ?? "",
            unit_number: unit.unitNumber ?? "",
            resident_id: unit.residentId ?? "",
            bsc_id: unit.bscId,
            bi_id: unit.biId,
            handover_date: unit.handoverDate.map { formatter.string(from: $0) },
            key_handover_date: keyHandoverDateString,  // Using today's date here
            key_handover_note: note
        )

        let body = try JSONEncoder().encode(updateRequest)

        let response: APIResponse<Unit2> = try await networkManager.request(
            endpoint: endpoint,
            method: .PUT,
            body: body
        )

        guard response.success, let updatedUnit = response.data else {
            throw NetworkError.serverError(response.code ?? 0)
        }

        return updatedUnit
    }
    
    func updateUnitKeyOptional(_ unit: Unit2, keyDate: Date?, note: String?) async throws -> Unit2 {
        let endpoint = "/property/v1/units/\(unit.id)"
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let keyHandoverDateString = keyDate.map { formatter.string(from: $0) }
        
        let updateRequest = UpdateUnitRequest(
            name: unit.name ?? "",
            unit_code_id: unit.unitCodeId ?? "",
            unit_number: unit.unitNumber ?? "",
            resident_id: unit.residentId ?? "",
            bsc_id: unit.bscId,
            bi_id: unit.biId,
            handover_date: unit.handoverDate.map { formatter.string(from: $0) },
            key_handover_date: keyHandoverDateString, // can be nil
            key_handover_note: note
        )
        
        let body = try JSONEncoder().encode(updateRequest)
        
        let response: APIResponse<Unit2> = try await networkManager.request(
            endpoint: endpoint,
            method: .PUT,
            body: body
        )
        
        guard response.success, let updatedUnit = response.data else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        
        return updatedUnit
    }


}

