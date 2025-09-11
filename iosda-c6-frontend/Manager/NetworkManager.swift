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
    
    var bearerToken: String? = "eyJhbGciOiJFZERTQSJ9.eyJ1c2VyX2lkIjoiMmI0YzU5YmQtMDQ2MC00MjZiLWE3MjAtODBjY2Q4NWVkNWIyIiwibmFtZSI6IlN1cGVyIEFkbWluaXN0cmF0b3IiLCJ1c2VybmFtZSI6InN1cGVyYWRtaW4iLCJlbWFpbCI6ImFkbWluQGV4YW1wbGUuY29tIiwicm9sZXMiOlsic3VwZXJfYWRtaW4iXSwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnBlcm1pc3Npb24iLCJjcmVhdGU6cm9sZSIsImNyZWF0ZTp1c2VyIiwiZGVsZXRlOnBlcm1pc3Npb24iLCJkZWxldGU6cm9sZSIsImRlbGV0ZTp1c2VyIiwibWFuYWdlOnJvbGVfcGVybWlzc2lvbnMiLCJyZWFkOmRlbGV0ZWRfcGVybWlzc2lvbnMiLCJyZWFkOmRlbGV0ZWRfcm9sZXMiLCJyZWFkOmRlbGV0ZWRfdXNlcnMiLCJyZWFkOnBlcm1pc3Npb24iLCJyZWFkOnBlcm1pc3Npb25zIiwicmVhZDpyb2xlIiwicmVhZDpyb2xlcyIsInJlYWQ6dXNlciIsInJlYWQ6dXNlcnMiLCJyZXN0b3JlOnBlcm1pc3Npb24iLCJyZXN0b3JlOnJvbGUiLCJyZXN0b3JlOnVzZXIiLCJ1cGRhdGU6cGVybWlzc2lvbiIsInVwZGF0ZTpyb2xlIiwidXBkYXRlOnVzZXIiXSwiaWF0IjoxNzU3NDY5NjkxLCJleHAiOjE3NTc1NTYwOTEsIm5iZiI6MTc1NzQ2OTY5MSwianRpIjoiZGMyMGE5Y2EtNmQ4MS00MGQ4LTk4OTgtZGJmZDhjMzdlMWJmIn0.Y0H3f4y6liFdtuafo_QkpIn7hH7RBHbf0bpBk5iNbWG0RhNAJ1y_dDC-pO-k19Ki0z_R5l8TEIPtjqgt6-_ZDA"
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
            print("Request body: \(String(data: body, encoding: .utf8) ?? "")")
        }

        print("Requesting URL: \(request.url?.absoluteString ?? "") with method: \(method.rawValue)")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Response status code: \(httpResponse.statusCode)")
        }

        print("Response data: \(String(data: data, encoding: .utf8) ?? "")")

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(0)
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder.iso8601WithFractionalSeconds

        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
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

