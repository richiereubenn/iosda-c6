//
//  BSCBIComplainDetailViewModel.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 09/09/25.
//

import Foundation
import SwiftUI

@MainActor
class BSCBIComplaintDetailViewModel: ObservableObject {
    @Published var selectedComplaint: Complaint2? = nil
    @Published var selectedStatus: ComplaintStatus? = nil
    @Published var isLoading: Bool = false
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String? = nil
    
    private let service: ComplaintServiceProtocol2
    
    init(service: ComplaintServiceProtocol2 = ComplaintService2()) {
        self.service = service
    }
    
    func loadComplaint(byId id: String) async {
        do {
            let complaint = try await service.getComplaintById(id)
            selectedComplaint = complaint
            selectedStatus = ComplaintStatus(raw: complaint.statusName)
        } catch {
            errorMessage = "Failed to load complaint \(id): \(error.localizedDescription)"
        }
    }
    
    func updateStatus(to statusId: String) async {
        guard let complaint = selectedComplaint else {
            errorMessage = "No complaint selected"
            return
        }
        
        isUpdating = true
        defer { isUpdating = false }
        
        do {
            let updatedComplaint = try await service.updateComplaintStatus(
                complaintId: complaint.id,
                statusId: statusId
            )
            
            let complainDetail = try await service.getComplaintById(updatedComplaint.id)
            
            selectedComplaint = complainDetail
            selectedStatus = ComplaintStatus(raw: complainDetail.statusName)
            print(complainDetail.statusName)
        } catch {
            errorMessage = "Failed to update status: \(error.localizedDescription)"
        }
    }
    
    func shouldShowActions(for status: ComplaintStatus?) -> Bool {
        guard let status else { return false }
        switch status {
        case .underReview:
            return true
        default:
            return false
        }
    }

}

