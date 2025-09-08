//
//  ComplainDetailViewModel2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 09/09/25.
//

import Foundation
import SwiftUI

@MainActor
class ComplaintDetailViewModel2: ObservableObject {
    @Published var selectedComplaint: Complaint2? = nil
    @Published var selectedStatus: ComplaintStatus? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let service: ComplaintServiceProtocol2
    
    init(service: ComplaintServiceProtocol2 = ComplaintService2()) {
        self.service = service
    }
    
    func loadComplaint(byId id: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let complaint = try await service.getComplaintById(id)

            selectedComplaint = complaint
            selectedStatus = ComplaintStatus(raw: complaint.statusName)
            
        } catch {
            errorMessage = "Failed to load complaint \(id): \(error.localizedDescription)"
        }
    }
}
