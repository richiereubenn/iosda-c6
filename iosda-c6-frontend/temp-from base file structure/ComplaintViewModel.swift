//
//  ComplaintViewModel.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import Foundation

@MainActor
class ComplaintViewModel: ObservableObject {
    @Published var complaints: [ComplaintModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let complaintService: ComplainServiceProtocol
    
    init(complaintService: ComplainServiceProtocol = ComplainService()) {
        self.complaintService = complaintService
    }
    
    func loadComplaints() async {
        isLoading = true
        errorMessage = nil
        
        do {
            complaints = try await complaintService.getAllComplaints()
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading complaints: \(error)")
        }
        
        isLoading = false
    }
    
    func refreshComplaints() async {
        await loadComplaints()
    }
}
