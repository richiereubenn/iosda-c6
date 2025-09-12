//
//  BlockService.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 12/09/25.
//

import Foundation

protocol BlockServiceProtocol {
    func getAllBlocks() async throws -> [Block]
    func getBlockById(_ id: String) async throws -> Block
}

class BlockService: BlockServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllBlocks() async throws -> [Block] {
        let response: APIResponse<[Block]> = try await networkManager.request(endpoint: "/property/v1/blocks")
        
        guard response.success else {
            throw NetworkError.serverError(0)
        }
        
        guard let blocks = response.data else {
            throw NetworkError.decodingError
        }
        
        return blocks
    }
    
    func getBlockById(_ id: String) async throws -> Block {
        let endpoint = "/property/v1/blocks/\(id)"
        let response: APIResponse<Block> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        guard let block = response.data else {
            throw NetworkError.noData
        }
        return block
    }
}
