//
//  ResidentAddComplaintViewModel.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 13/09/25.
//


import Foundation
import SwiftUI

@MainActor
class ResidentAddComplaintViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var complaints: [Complaint2] = []

    
    private let complaintService: ComplaintServiceProtocol2

    init(complaintService: ComplaintServiceProtocol2 = ComplaintService2()) {
        self.complaintService = complaintService
    }

    func submitComplaint(request: CreateComplaintRequest2, selectedUnit: Unit2) async {
        isLoading = true
        errorMessage = nil
        
        let fixedStatusId = "661a5a05-730b-4dc3-a924-251a1db7a2d7"
        

        // Create a modified request with key handover data added
        let fullRequest = CreateComplaintRequest2(
            unitId: request.unitId,
            userId: request.userId,
            statusId: fixedStatusId,
            classificationId: request.classificationId,
            title: request.title,
            description: request.description,
            latitude: request.latitude,
            longitude: request.longitude,
            handoverMethod: request.handoverMethod,
            keyHandoverDate: selectedUnit.keyHandoverDate,
            keyHandoverNote: selectedUnit.keyHandoverNote
        )

        do {
            _ = try await complaintService.submitComplaint(request: fullRequest)
            await loadComplaints()
        } catch {
            print("❌ Error submitting complaint: \(error.localizedDescription)")
            errorMessage = "Failed to submit complaint. Please try again later."
        }

        isLoading = false
    }

    func loadComplaints() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            complaints = try await complaintService.getAllComplaints()
        } catch {
            print("❌ Failed to load complaints: \(error.localizedDescription)")
            errorMessage = "Failed to load complaints."
        }
    }
    


    
    func submitInHouseComplaint(
        title: String,
        description: String,
        unitId: String,
        userId: String,
        statusId: String,
        classificationId: String,
        latitude: Double,
        longitude: Double,
        handoverMethod: HandoverMethod,
        selectedUnit: Unit2
    ) async {
        let fixedStatusId = "661a5a05-730b-4dc3-a924-251a1db7a2d7"
        // Create request without key handover date and note
        let request = CreateComplaintRequest2(
            unitId: unitId,
            userId: userId,
            statusId: fixedStatusId,
            classificationId: classificationId,
            title: title,
            description: description,
            latitude: latitude,
            longitude: longitude,
            handoverMethod: handoverMethod,
            keyHandoverDate: nil,
            keyHandoverNote: nil
        )
        
        await submitComplaint(request: request, selectedUnit: selectedUnit)
    }

}
