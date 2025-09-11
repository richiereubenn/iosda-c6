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
    @Published var classifications: [Classification] = []
    @Published var firstProgress: ProgressLog2? = nil
    @Published var isLoading: Bool = false
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isSubmitting: Bool = false
    @Published var selectedCategory: String? = nil
    @Published var selectedWorkDetail: String? = nil
    let defaultClassificationId = "75b125fd-a656-4fd8-a500-2f051b068171"
    private let service: ComplaintServiceProtocol2
    private let progressService: ProgressLogServiceProtocol
    private let classificationService: ClassificationServiceProtocol
    
    private let baseURL = "https://api.kevinchr.com/complaint"
    
    init(
        service: ComplaintServiceProtocol2 = ComplaintService2(),
        progressService: ProgressLogServiceProtocol = ProgressLogService(),
        classificationService: ClassificationServiceProtocol = ClassificationService()
    ) {
        self.service = service
        self.progressService = progressService
        self.classificationService = classificationService
    }
    
    func loadComplaint(byId id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let complaint = try await service.getComplaintById(id)
            selectedComplaint = complaint
            selectedStatus = ComplaintStatus(raw: complaint.statusName)
            
            await loadFirstProgress(for: id)
        } catch {
            errorMessage = "Failed to load complaint \(id): \(error.localizedDescription)"
        }
    }
    
    private func loadFirstProgress(for complaintId: String) async {
        do {
            firstProgress = try await progressService.getFirstProgress(complaintId: complaintId)
        } catch {
            print("Failed to load first progress: \(error.localizedDescription)")
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
        } catch {
            errorMessage = "Failed to update status: \(error.localizedDescription)"
        }
    }
    
    func shouldShowActions(for status: ComplaintStatus?) -> Bool {
        guard let status else { return false }
        switch status {
        case .underReviewbByBSC:
            return true
        default:
            return false
        }
    }
    
    var firstProgressImageURLs: [String] {
        firstProgress?.files?.compactMap { file in
            fullURL(for: file.url)
        } ?? []
    }
    
    private func fullURL(for path: String?) -> String {
        guard let path else { return "" }
        if path.hasPrefix("http") {
            return path
        } else {
            return baseURL + path
        }
    }
    
    func submitRejectionProgress(complaintId: String,
                                 userId: String,
                                 reason: String) async {
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            _ = try await progressService.createProgress(
                complaintId: complaintId,
                userId: userId,
                title: "reject info",
                description: reason,
                files: nil
            )
        } catch {
            errorMessage = "Failed to create rejection progress: \(error.localizedDescription)"
        }
    }
    
    func submitStartWorkProgress(
        complaintId: String,
        userId: String,
        images: [UIImage],
        title: String,
        description: String
    ) async {
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            _ = try await progressService.uploadProgressWithFiles(
                complaintId: complaintId,
                userId: userId,
                title: title,
                description: description,
                images: images
            )
        } catch {
            errorMessage = "Failed to create start work progress: \(error.localizedDescription)"
        }
    }
    
    func loadClassifications(defaultId: String? = nil) async {
        do {
            let fetched = try await classificationService.fetchClassification()
            classifications = fetched

            if let id = defaultId,
               let classification = fetched.first(where: { $0.id == id }) {
                selectedCategory = classification.name
                selectedWorkDetail = classification.workDetail
            }

        } catch {
            errorMessage = "Failed to load classifications: \(error.localizedDescription)"
        }
    }

    
    var uniqueCategories: [String] {
        Array(Set(classifications.map { $0.name })).sorted()
    }
    
    var workDetailsForSelectedCategory: [String] {
        guard let category = selectedCategory else { return [] }
        return classifications
            .filter { $0.name == category }
            .map { $0.workDetail ?? "-" }
    }
}
