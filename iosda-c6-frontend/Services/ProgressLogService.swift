//
//  ProgressLogService.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 09/09/25.
//

import Foundation
import UIKit

protocol ProgressLogServiceProtocol {
    func getAllProgress(complaintId: String) async throws -> [ProgressLog2]
    func getFirstProgress(complaintId: String) async throws -> ProgressLog2?
    func createProgress(complaintId: String,
                        userId: String,
                        title: String,
                        description: String?,
                        files: [String]?) async throws -> ProgressLog2
    func uploadProgressWithFiles(
            complaintId: String,
            userId: String,
            title: String,
            description: String?,
            images: [UIImage]
        ) async throws -> ProgressLog2
}

class ProgressLogService: ProgressLogServiceProtocol {
    private let baseURL = "https://api.kevinchr.com"
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllProgress(complaintId: String) async throws -> [ProgressLog2] {
        let endpoint = "/complaint/v1/complaints/\(complaintId)/progress?page=1&limit=100"
        
        let response: APIResponse<[ProgressLog2]> = try await networkManager.request(endpoint: endpoint)
        
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        
        return response.data ?? []
    }
    
    func getFirstProgress(complaintId: String) async throws -> ProgressLog2? {
        let logs = try await getAllProgress(complaintId: complaintId)
        
        let sortedLogs = logs.sorted {
            guard let date1 = $0.createdAt, let date2 = $1.createdAt else {
                return $0.createdAt != nil
            }
            return date1 < date2
        }
        
        return sortedLogs.last
    }

    
    func createProgress(complaintId: String,
                        userId: String,
                        title: String,
                        description: String? = nil,
                        files: [String]? = nil) async throws -> ProgressLog2 {
        
        let endpoint = "/complaint/v1/complaints/\(complaintId)/progress"
        
        var bodyDict: [String: Any] = [
            "user_id": userId,
            "title": title
        ]
        
        if let description = description {
            bodyDict["description"] = description
        }
        if let files = files {
            bodyDict["files"] = files 
        }
        
        let body = try JSONSerialization.data(withJSONObject: bodyDict)
        
        let response: APIResponse<ProgressLog2> = try await networkManager.request(
            endpoint: endpoint,
            method: .POST,
            body: body
        )
        
        guard response.success, let progress = response.data else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        
        return progress
    }

    func uploadProgressWithFiles(
        complaintId: String,
        userId: String,
        title: String,
        description: String?,
        images: [UIImage]
    ) async throws -> ProgressLog2 {
        
        guard let url = URL(string: baseURL + "/complaint/v1/complaints/\(complaintId)/progress") else {
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
        
        body.appendFormField(name: "user_id", value: userId, boundary: boundary)
        body.appendFormField(name: "title", value: title, boundary: boundary)
        
        if let description = description {
            body.appendFormField(name: "description", value: description, boundary: boundary)
        }
        
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                body.appendFileField(
                    name: "files",
                    fileName: "image_\(index).jpg",
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
        let apiResponse = try decoder.decode(APIResponse<ProgressLog2>.self, from: data)
        
        guard apiResponse.success, let progressLog = apiResponse.data else {
            throw NetworkError.serverError(apiResponse.code ?? 0)
        }
        
        return progressLog
    }

    
}


extension Data {
    mutating func appendFormField(name: String, value: String, boundary: String) {
        self.append("--\(boundary)\r\n".data(using: .utf8)!)
        self.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        self.append("\(value)\r\n".data(using: .utf8)!)
    }
    
    mutating func appendFileField(name: String, fileName: String, mimeType: String, fileData: Data, boundary: String) {
        self.append("--\(boundary)\r\n".data(using: .utf8)!)
        self.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        self.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        self.append(fileData)
        self.append("\r\n".data(using: .utf8)!)
    }
    
    mutating func closeMultipart(boundary: String) {
        self.append("--\(boundary)--\r\n".data(using: .utf8)!)
    }
}
