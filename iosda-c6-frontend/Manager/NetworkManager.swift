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
    var bearerToken: String? 
//    var bearerToken: String? = "eyJhbGciOiJFZERTQSJ9.eyJ1c2VyX2lkIjoiNjBkMTc3ZTktYzJkYy00NmViLThkZDgtYmE1MTA5MWRjODdhIiwibmFtZSI6IlN1cGVyIEFkbWluIiwidXNlcm5hbWUiOiJzdXBlcmFkbWluIiwiZW1haWwiOiJzdXBlcmFkbWluQG1haWwudGVzdCIsInJvbGVzIjpbImFkbWluIl0sInBlcm1pc3Npb25zIjpbImNyZWF0ZTphcmVhIiwiY3JlYXRlOmJsb2NrIiwiY3JlYXRlOmNsYXNzaWZpY2F0aW9uIiwiY3JlYXRlOmNvbXBsYWludCIsImNyZWF0ZTpjb250cmFjdG9yIiwiY3JlYXRlOmZpbGUiLCJjcmVhdGU6cGVybWlzc2lvbiIsImNyZWF0ZTpwcm9ncmVzcyIsImNyZWF0ZTpwcm9qZWN0IiwiY3JlYXRlOnJvbGUiLCJjcmVhdGU6c3RhdHVzIiwiY3JlYXRlOnVuaXQiLCJjcmVhdGU6dW5pdF9jb2RlIiwiY3JlYXRlOnVzZXIiLCJkZWxldGU6YXJlYSIsImRlbGV0ZTpibG9jayIsImRlbGV0ZTpjbGFzc2lmaWNhdGlvbiIsImRlbGV0ZTpjb21wbGFpbnQiLCJkZWxldGU6Y29udHJhY3RvciIsImRlbGV0ZTpmaWxlIiwiZGVsZXRlOnBlcm1pc3Npb24iLCJkZWxldGU6cHJvZ3Jlc3MiLCJkZWxldGU6cHJvamVjdCIsImRlbGV0ZTpyb2xlIiwiZGVsZXRlOnN0YXR1cyIsImRlbGV0ZTp1bml0IiwiZGVsZXRlOnVuaXRfY29kZSIsImRlbGV0ZTp1c2VyIiwibWFuYWdlOnJvbGVfcGVybWlzc2lvbnMiLCJyZWFkOmFyZWEiLCJyZWFkOmJsb2NrIiwicmVhZDpjbGFzc2lmaWNhdGlvbiIsInJlYWQ6Y29tcGxhaW50IiwicmVhZDpjb21wbGFpbnRzIiwicmVhZDpjb250cmFjdG9yIiwicmVhZDpkZWxldGVkX3Blcm1pc3Npb25zIiwicmVhZDpkZWxldGVkX3JvbGVzIiwicmVhZDpkZWxldGVkX3VzZXJzIiwicmVhZDpmaWxlIiwicmVhZDpwZXJtaXNzaW9uIiwicmVhZDpwZXJtaXNzaW9ucyIsInJlYWQ6cHJvZ3Jlc3MiLCJyZWFkOnByb2plY3QiLCJyZWFkOnJvbGUiLCJyZWFkOnJvbGVzIiwicmVhZDpzZXNzaW9uIiwicmVhZDpzZXNzaW9ucyIsInJlYWQ6c3RhdHVzIiwicmVhZDp1bml0IiwicmVhZDp1bml0X2NvZGUiLCJyZWFkOnVuaXRzIiwicmVhZDp1c2VyIiwicmVhZDp1c2VycyIsInJlc3RvcmU6cGVybWlzc2lvbiIsInJlc3RvcmU6cm9sZSIsInJlc3RvcmU6dXNlciIsInJldm9rZTpzZXNzaW9uIiwidXBkYXRlOmFyZWEiLCJ1cGRhdGU6YmxvY2siLCJ1cGRhdGU6Y2xhc3NpZmljYXRpb24iLCJ1cGRhdGU6Y29tcGxhaW50IiwidXBkYXRlOmNvbnRyYWN0b3IiLCJ1cGRhdGU6ZmlsZSIsInVwZGF0ZTpwZXJtaXNzaW9uIiwidXBkYXRlOnByb2dyZXNzIiwidXBkYXRlOnByb2plY3QiLCJ1cGRhdGU6cm9sZSIsInVwZGF0ZTpzdGF0dXMiLCJ1cGRhdGU6dW5pdCIsInVwZGF0ZTp1bml0X2NvZGUiLCJ1cGRhdGU6dXNlciJdLCJpYXQiOjE3NTc1NTU3MzMsImV4cCI6MTc1ODE2MDUzMywibmJmIjoxNzU3NTU1NzMzLCJqdGkiOiI0MDQ0ZDVhZi1mYTY0LTQ5MzItOGFiMy1mNWE1Y2FiNTRmOTkifQ.bkbLRPCxSB8GbHolitnD6fEqBkBkJeIqBRP1OMTi1op17yFGZNpfLm7cH-fMd3AgDnfV9p6MKFePYbG4w7ydDQ"
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

extension NetworkManager {
    func getUserIdFromToken() -> String? {
        guard let token = bearerToken else { return nil }
        
        let segments = token.split(separator: ".")
        guard segments.count > 1 else { return nil }
        
        let payloadSegment = segments[1]
        
        // Base64URL decode
        var base64 = payloadSegment
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Tambahkan padding kalau perlu
        while base64.count % 4 != 0 {
            base64.append("=")
        }
        
        guard let data = Data(base64Encoded: base64),
              let payload = try? JSONDecoder().decode(JWTPayload.self, from: data) else {
            return nil
        }
        
        return payload.user_id
    }
}

