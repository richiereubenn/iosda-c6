//
//  ComplaintService2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 08/09/25.
//

import Foundation

protocol ComplaintServiceProtocol2 {
    func getAllComplaints() async throws -> [Complaint2]
    func getComplaintsByUnitId(_ unitId: String) async throws -> [Complaint2]
    func getComplaintById(_ id: String) async throws -> Complaint2
    func updateComplaintStatus(complaintId: String, statusId: String) async throws -> Complaint2
    func getComplaintsByUserId(_ userId: String) async throws -> [Complaint2]
    func getProgressLogs(complaintId: String) async throws -> [ProgressLog]
    func updateComplaint(complaintId: String, classificationId: String) async throws -> Complaint2
    func submitComplaint(request: CreateComplaintRequest2) async throws -> Complaint2
    func updateComplaintHandoverMethod(complaintId: String, newMethod: HandoverMethod) async throws -> Complaint2
    func updateComplaintClassification(complaintId: String, classificationId: String) async throws -> Complaint2
    
}

class ComplaintService2: ComplaintServiceProtocol2 {
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func getAllComplaints() async throws -> [Complaint2] {
        let response: APIResponse<[Complaint2]> = try await networkManager.request(endpoint: "/complaint/v1/complaints")
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        return response.data ?? []
    }
    
    func getComplaintsByUnitId(_ unitId: String) async throws -> [Complaint2] {
        let endpoint = "/complaint/v1/complaints?unit_id=\(unitId)"
        let response: APIResponse<[Complaint2]> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        return response.data ?? []
    }
    
    func getComplaintById(_ id: String) async throws -> Complaint2 {
        let endpoint = "/complaint/v1/complaints/\(id)"
        let response: APIResponse<Complaint2> = try await networkManager.request(endpoint: endpoint)
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        guard let complaint = response.data else {
            throw NetworkError.noData
        }
        return complaint
    }
    
    func updateComplaint(complaintId: String, classificationId: String) async throws -> Complaint2 {
            let endpoint = "/complaint/v1/complaints/\(complaintId)"
            
            let bodyDict: [String: Any] = [
                "classification_id": classificationId
            ]
            let bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
            
            let response: APIResponse<Complaint2> = try await networkManager.request(
                endpoint: endpoint,
                method: .PUT,
                body: bodyData
            )
            
            guard response.success else {
                throw NetworkError.serverError(response.code ?? 0)
            }
            
            guard let updatedComplaint = response.data else {
                throw NetworkError.noData
            }
            
            return updatedComplaint
        }
    
    func updateComplaintStatus(complaintId: String, statusId: String) async throws -> Complaint2 {
            let endpoint = "/complaint/v1/complaints/\(complaintId)/status"
            
            let bodyDict: [String: Any] = ["status_id": statusId]
            let bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
            
            let response: APIResponse<Complaint2> = try await networkManager.request(
                endpoint: endpoint,
                method: .PUT,
                body: bodyData
            )
            
            guard response.success else {
                throw NetworkError.serverError(response.code ?? 0)
            }
            
            guard let updatedComplaint = response.data else {
                throw NetworkError.noData
            }
            
            return updatedComplaint
        }

    func updateComplaintHandoverMethod(complaintId: String, newMethod: HandoverMethod) async throws -> Complaint2 {
        let endpoint = "/complaint/v1/complaints/\(complaintId)"
        
        let bodyDict: [String: Any] = [
            "handover_method": newMethod.rawValue
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
        
        let response: APIResponse<Complaint2> = try await networkManager.request(
            endpoint: endpoint,
            method: .PUT,
            body: bodyData
        )
        
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        
        guard let updatedComplaint = response.data else {
            throw NetworkError.noData
        }
        
        return updatedComplaint
    
    }
    
    func updateComplaintClassification(
        complaintId: String,
        classificationId: String
    ) async throws -> Complaint2 {
        let endpoint = "/complaint/v1/complaints/\(complaintId)"
        
        let bodyDict: [String: Any] = [
            "classification_id": classificationId
        ]
        let bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
        
        let response: APIResponse<Complaint2> = try await networkManager.request(
            endpoint: endpoint,
            method: .PUT, // if backend supports PATCH, prefer that
            body: bodyData
        )
        
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        
        guard let updatedComplaint = response.data else {
            throw NetworkError.noData
        }
        
        return updatedComplaint
    }


    
    func getProgressLogs(complaintId: String) async throws -> [ProgressLog] {
            let endpoint = "/complaint/v1/complaints/\(complaintId)/progress"
            
            let response: APIResponse<[ProgressLog]> = try await networkManager.request(endpoint: endpoint)
            
            guard response.success else {
                throw NetworkError.serverError(response.code ?? 0)
            }
            
            return response.data ?? []
        }
    

    func getComplaintsByUserId(_ userId: String) async throws -> [Complaint2] {

        let endpoint = "/complaint/v1/complaints?page=1&limit=100&user_id=\(userId)"
        let response: APIResponse<[Complaint2]> = try await networkManager.request(endpoint: endpoint)
        
 
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        

        guard let updatedComplaint = response.data else {
            throw NetworkError.noData
        }
        
        return updatedComplaint
    }
    
    func submitComplaint(request: CreateComplaintRequest2) async throws -> Complaint2 {
        let endpoint = "/complaint/v1/complaints"
        let bodyData = try JSONEncoder().encode(request)
        
        let response: APIResponse<Complaint2> = try await networkManager.request(
            endpoint: endpoint,
            method: .POST,
            body: bodyData
        )
        
        guard response.success else {
            throw NetworkError.serverError(response.code ?? 0)
        }
        
        guard let complaint = response.data else {
            throw NetworkError.noData
        }
        
        return complaint
    }

}

