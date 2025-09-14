//
//  KeyLogService.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 14/09/25.
//

import Foundation
import UIKit

protocol KeyLogServiceProtocol {
    func getLastKeyLog(unitId: String) async throws -> KeyLog?
    func getAllKeyLog(unitId: String) async throws -> [KeyLog]
    func createKeyLog(unitId: String, userId: String, detail: String) async throws -> KeyLog
}

class KeyLogService: KeyLogServiceProtocol {
    private let baseURL = "https://api.kevinchr.com"
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllKeyLog(unitId: String) async throws -> [KeyLog] {
        let endpoint = "/property/v1/key-logs?unit_id=\(unitId)"
        
        let response: APIResponse<[KeyLog]> = try await networkManager.request(endpoint: endpoint)
        
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        
        return response.data ?? []
    }
    
    func getLastKeyLog(unitId: String) async throws -> KeyLog? {
        let logs = try await getAllKeyLog(unitId: unitId)
        
        let sortedLogs = logs.sorted {
            guard let date1 = $0.createdAt, let date2 = $1.createdAt else {
                return $0.createdAt != nil
            }
            return date1 < date2
        }
        
        return sortedLogs.last
    }

    
    func createKeyLog(unitId: String, userId: String, detail: String) async throws -> KeyLog {
        
        let endpoint = "property/v1/key-logs/\(unitId)/progress"
        
        var bodyDict: [String: Any] = [
            "user_id": userId,
            "unit_id": unitId,
            "detail": detail
        ]
        
        let body = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let response: APIResponse<KeyLog> = try await networkManager.request(
            endpoint: endpoint,
            method: .POST,
            body: body
        )
        
        guard response.success, let keyLog = response.data else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        
        return keyLog
    }
}
