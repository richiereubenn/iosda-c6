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
    func uploadKeyLogWithFiles(
            unitId: String,
            userId: String,
            detail: String,
            images: [UIImage]
        ) async throws -> KeyLog
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
        
        let endpoint = "/property/v1/key-logs"
        
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
    
    func uploadKeyLogWithFiles(
            unitId: String,
            userId: String,
            detail: String,
            images: [UIImage]
        ) async throws -> KeyLog {
            
            guard let url = URL(string: baseURL + "/property/v1/key-logs") else {
                throw NetworkError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            if let token = networkManager.bearerToken {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            // fields
            body.appendFormField(name: "unit_id", value: unitId, boundary: boundary)
            body.appendFormField(name: "user_id", value: userId, boundary: boundary)
            body.appendFormField(name: "detail", value: detail, boundary: boundary)
            
            // files
            for (index, image) in images.enumerated() {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    body.appendFileField(
                        name: "files",
                        fileName: "keylog_\(index).jpg",
                        mimeType: "image/jpeg",
                        fileData: imageData,
                        boundary: boundary
                    )
                }
            }
            
            body.closeMultipart(boundary: boundary)
            
            let (data, response) = try await URLSession.shared.upload(for: request, from: body)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            
            let decoder = JSONDecoder.iso8601WithFractionalSeconds
            let apiResponse = try decoder.decode(APIResponse<KeyLog>.self, from: data)
            
            guard apiResponse.success, let keyLog = apiResponse.data else {
                throw NetworkError.serverError(apiResponse.code ?? 0)
            }
            
            return keyLog
        
    }
}
