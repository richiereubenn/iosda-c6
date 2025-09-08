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
            let data = try await service.fetchComplaints()
            complaints = data
            applyFilters()
        } catch {
            errorMessage = "Failed to load complaints: \(error.localizedDescription)"
        }
    }
    
    private func applyFilters() {
        var results = complaints
        
        switch selectedFilter {
        case .all:
            break
        case .open:
            results = results.filter { $0.statusName?.lowercased() == "open" }
        case .underReview:
            results = results.filter { $0.statusName?.lowercased() == "under review" }
        case .waitingKey:
            results = results.filter { $0.statusName?.lowercased() == "waiting key" }
        case .inProgress:
            results = results.filter { $0.statusName?.lowercased() == "in progress" }
        case .resolved:
            results = results.filter { $0.statusName?.lowercased() == "resolved" }
        case .rejected:
            results = results.filter { $0.statusName?.lowercased() == "rejected" }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            results = results.filter {
                ($0.title ?? "").lowercased().contains(query) ||
                ($0.description ?? "").lowercased().contains(query)
            }
        }

        
        filteredComplaints = results
    }
    
    enum ComplaintFilter: String, CaseIterable {
        case all = "All"
        case open = "Open"
        case underReview = "Under Review"
        case waitingKey = "Waiting Key"
        case inProgress = "In Progress"
        case resolved = "Resolved"
        case rejected = "Rejected"
    }
}
