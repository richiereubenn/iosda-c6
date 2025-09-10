//
//  ComplaintListViewModel2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 08/09/25.
//

import Foundation
import SwiftUI

@MainActor
class ComplaintListViewModel2: ObservableObject {
    @Published var complaints: [Complaint2] = []
    @Published var filteredComplaints: [Complaint2] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var selectedFilter: ComplaintFilter = .all {
        didSet { applyFilters() }
    }
    @Published var searchText: String = "" {
        didSet { applyFilters() }
    }
    
    private let service: ComplaintServiceProtocol2
    
    init(service: ComplaintServiceProtocol2 = ComplaintService2()) {
        self.service = service
    }
    
    func loadComplaints() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data = try await service.getAllComplaints()
            complaints = data
            applyFilters()
        } catch {
            errorMessage = "Failed to load complaints: \(error.localizedDescription)"
        }
    }
    
    func loadComplaints(byUserId userId: String) async {
            isLoading = true
            defer { isLoading = false }
            
            do {
                complaints = try await service.getComplaintsByUserId(userId)
                applyFilters()
            } catch {
                errorMessage = "Failed to load your complaints: \(error.localizedDescription)"
            }
        }
    
    func loadComplaints(byUnitId unitId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data = try await service.getComplaintsByUnitId(unitId)
            complaints = data
            applyFilters()
        } catch {
            errorMessage = "Failed to load complaints for unit \(unitId): \(error.localizedDescription)"
        }
    }
    
    private func applyFilters() {
        var results = complaints
        
        switch selectedFilter {
        case .all:
            break
        case .underReviewByBI:
            results = results.filter { $0.statusName?.lowercased() == "under review by bi" }
        case .underReviewByBSC:
            results = results.filter { $0.statusName?.lowercased() == "under review by bsc" }
        case .assignToVendor:
            results = results.filter { $0.statusName?.lowercased() == "assign to vendor" }
        case .waitingKey :
            results = results.filter { $0.statusName?.lowercased() == "waiting key handover" }
        case .inProgress:
            results = results.filter { $0.statusName?.lowercased() == "in progress" }
        case .close:
            results = results.filter { $0.statusName?.lowercased() == "resolved" || $0.statusName?.lowercased() == "rejected"}
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter {
                $0.title.lowercased().contains(query) ||
                $0.description.lowercased().contains(query)
            }
        }
        
        filteredComplaints = results
    }
    
    enum ComplaintFilter: String, CaseIterable {
        case all = "All"
        case underReviewByBI = "BI Review"
        case underReviewByBSC = "BSC Review"
        case assignToVendor = "Assign To Vendor"
        case waitingKey = "Key Handover"
        case inProgress = "In Progress"
        case close = "Close"
    }
}
