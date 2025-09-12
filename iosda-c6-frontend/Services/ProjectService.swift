//
//  ProjectService.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 12/09/25.
//

import Foundation

protocol ProjectServiceProtocol {
    func getAllProjects() async throws -> [Project]
    func getProjectById(_ id: String) async throws -> Project
}

class ProjectService: ProjectServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllProjects() async throws -> [Project] {
        let response: APIResponse<[Project]> = try await networkManager.request(endpoint: "/property/v1/projects")
        
        guard response.success else {
            throw NetworkError.serverError(0)
        }
        
        guard let projects = response.data else {
            throw NetworkError.decodingError
        }
        
        return projects
    }
    
    func getProjectById(_ id: String) async throws -> Project {
        let endpoint = "/property/v1/projects/\(id)"
        let response: APIResponse<Project> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        guard let project = response.data else {
            throw NetworkError.noData
        }
        return project
    }
}
