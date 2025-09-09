//
//  NetworkManager.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import Foundation
import UIKit

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL tidak valid"
        case .noData:
            return "Data tidak ditemukan"
        case .decodingError:
            return "Gagal memproses data"
        case .serverError(let code):
            return "Server error dengan kode: \(code)"
        case .networkUnavailable:
            return "Koneksi internet tidak tersedia"
        }
    }
}
class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.kevinchr.com"
    
    var bearerToken: String? = "eyJhbGciOiJFZERTQSJ9.eyJ1c2VyX2lkIjoiMmI0YzU5YmQtMDQ2MC00MjZiLWE3MjAtODBjY2Q4NWVkNWIyIiwibmFtZSI6IlN1cGVyIEFkbWluaXN0cmF0b3IiLCJ1c2VybmFtZSI6InN1cGVyYWRtaW4iLCJlbWFpbCI6ImFkbWluQGV4YW1wbGUuY29tIiwicm9sZXMiOlsic3VwZXJfYWRtaW4iXSwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnBlcm1pc3Npb24iLCJjcmVhdGU6cm9sZSIsImNyZWF0ZTp1c2VyIiwiZGVsZXRlOnBlcm1pc3Npb24iLCJkZWxldGU6cm9sZSIsImRlbGV0ZTp1c2VyIiwibWFuYWdlOnJvbGVfcGVybWlzc2lvbnMiLCJyZWFkOmRlbGV0ZWRfcGVybWlzc2lvbnMiLCJyZWFkOmRlbGV0ZWRfcm9sZXMiLCJyZWFkOmRlbGV0ZWRfdXNlcnMiLCJyZWFkOnBlcm1pc3Npb24iLCJyZWFkOnBlcm1pc3Npb25zIiwicmVhZDpyb2xlIiwicmVhZDpyb2xlcyIsInJlYWQ6dXNlciIsInJlYWQ6dXNlcnMiLCJyZXN0b3JlOnBlcm1pc3Npb24iLCJyZXN0b3JlOnJvbGUiLCJyZXN0b3JlOnVzZXIiLCJ1cGRhdGU6cGVybWlzc2lvbiIsInVwZGF0ZTpyb2xlIiwidXBkYXRlOnVzZXIiXSwiaWF0IjoxNzU3MzgwMjcwLCJleHAiOjE3NTc0NjY2NzAsIm5iZiI6MTc1NzM4MDI3MCwianRpIjoiNTI4OWE1ZWItY2RlNS00YjllLTllZjYtMTRhZGFhYzdlODU3In0.6r_5P_JWDWVcFRRj3ciMZqii-dNlyW_e-8rhtGEmoyrzm-5ocWDL5hv-pxT6BX5uxpR_2LHAcJuJYYPJMiCoBA"
    private init() {}
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = bearerToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.serverError(0)
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder.iso8601WithFractionalSeconds
            return try decoder.decode(T.self, from: data)
        } catch {
            if error is DecodingError {
                throw NetworkError.decodingError
            }
            throw error
        }
    }
    
    func requestEmpty(
        endpoint: String,
        method: HTTPMethod = .GET
    ) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = bearerToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(0)
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

extension JSONDecoder {
    static var iso8601WithFractionalSeconds: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
}

extension NetworkManager {
    func createProgressWithFiles(
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
        
        if let token = bearerToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add text fields
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userId)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"title\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(title)\r\n".data(using: .utf8)!)
        
        if let description = description {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(description)\r\n".data(using: .utf8)!)
        }
        
        // Add image files
        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                continue
            }
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files\"; filename=\"image_\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
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
