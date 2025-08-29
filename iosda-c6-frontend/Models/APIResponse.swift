//
//  APIResponse.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

mport Foundation

struct APIResponse<T: Codable>: Codable {
    let data: T
    let message: String?
    let success: Bool
    
    var isSuccess: Bool {
        return success
    }
    
    var errorMessage: String {
        return message ?? "Terjadi kesalahan yang tidak diketahui"
    }
}

extension APIResponse {
    static func successResponse(message: String = "Berhasil") -> APIResponse<EmptyData> {
        return APIResponse<EmptyData>(
            data: EmptyData(),
            message: message,
            success: true
        )
    }
    
    static func errorResponse(message: String) -> APIResponse<EmptyData> {
        return APIResponse<EmptyData>(
            data: EmptyData(),
            message: message,
            success: false
        )
    }
}

struct EmptyData: Codable {
}

