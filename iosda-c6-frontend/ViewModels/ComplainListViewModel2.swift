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
    
    @Published var showKeyLogAlert: Bool = false
    @Published var showSystemAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var lastKeyLog: KeyLog? = nil
    @Published var buttonTitle: String = "Accept Key Handover"
    @Published var isButtonEnabled: Bool = false
    
    private let service: ComplaintServiceProtocol2
    private let keyLogService: KeyLogServiceProtocol
    private let progressLogService: ProgressLogServiceProtocol
    
    init(service: ComplaintServiceProtocol2 = ComplaintService2(),
         keyLogService: KeyLogServiceProtocol = KeyLogService(),
         progressLogService: ProgressLogServiceProtocol = ProgressLogService()) {
        self.service = service
        self.keyLogService = keyLogService
        self.progressLogService = progressLogService
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
            results = results.filter { $0.statusName?.lowercased() != "resolved" && $0.statusName?.lowercased() != "rejected"}
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
    
    func evaluateButton(unitId: String) async {
        guard let firstComplaint = complaints.first else {
            // Tidak ada complaint sama sekali
            isButtonEnabled = false
            buttonTitle = "Accept Key Handover"
            return
        }
        
        let handoverMethod = firstComplaint.handoverMethod
        let allResolvedOrRejected = complaints.allSatisfy {
            let status = $0.statusName?.lowercased() ?? ""
            return status == "resolved" || status == "rejected"
        }
        let anyWaitingKey = complaints.contains { $0.statusName?.lowercased() == "waiting key handover" }
        
        // ✅ Rule baru: inHouse + ada waiting key => langsung aktif
        if handoverMethod == .inHouse, anyWaitingKey {
            isButtonEnabled = true
            buttonTitle = "Accept Key Handover"
            return
        }
        
        // Kalau bukan inHouse, lanjut cek lastKeyLog
        lastKeyLog = try? await keyLogService.getLastKeyLog(unitId: unitId)
        let lastDetail = lastKeyLog?.detail ?? ""
        
        switch lastDetail {
        case "resident":
            isButtonEnabled = false
            buttonTitle = "Accept Key Handover"
            
        case "bsc":
            if anyWaitingKey {
                isButtonEnabled = true
                buttonTitle = "Accept Key Handover"
            } else if allResolvedOrRejected {
                isButtonEnabled = true
                buttonTitle = "Return Key"
            } else {
                isButtonEnabled = false
                buttonTitle = "Return Key"
            }
            
        default:
            isButtonEnabled = false
            buttonTitle = "Accept Key Handover"
        }
    }

    
    func handleButtonTap(unitId: String, userId: String) async {
        lastKeyLog = try? await keyLogService.getLastKeyLog(unitId: unitId)
        
        // Tombol Return Key -> tidak perlu cek firstComplaint
        if buttonTitle == "Return Key" {
            await createKeyLog(unitId: unitId, userId: userId, detail: "resident")
            return
        }
        
        // Tombol Accept Key Handover -> cek firstComplaint yang belum resolved/rejected
        guard let firstComplaint = complaints.first(where: { $0.statusName?.lowercased() != "resolved" && $0.statusName?.lowercased() != "rejected" }) else { return }
        
        let handoverMethod = firstComplaint.handoverMethod
        let hasWaitingKey = complaints.contains { $0.statusName?.lowercased() == "waiting key handover" }
        
        if hasWaitingKey {
            switch handoverMethod {
            case .inHouse:
                alertTitle = "Key Acceptance"
                showSystemAlert = true
            case .bringToMO:
                showKeyLogAlert = true
            default:
                await createKeyLog(unitId: unitId, userId: userId, detail: "resident")
            }
        } else {
            await createKeyLog(unitId: unitId, userId: userId, detail: "resident")
        }
    }


    
    func acceptKey(unitId: String, userId: String) async {
        let waitingComplaints = complaints.filter { $0.statusName?.lowercased() == "waiting key handover" }
        
        for complaint in waitingComplaints {
            do {
                let updatedComplaint = try await service.updateComplaintStatus(
                    complaintId: complaint.id,
                    statusId: "06d2b0a3-afc8-400c-b4b4-bdcee995f35f"
                )
                
                try await _=progressLogService.createProgress(complaintId: complaint.id, userId: userId, title: "Kunci diterima", description: "Kunci berhasil di terima oleh BSC", files: [])
                
                if let idx = complaints.firstIndex(where: { $0.id == updatedComplaint.id }) {
                    complaints[idx] = updatedComplaint
                }
                
            } catch {
                errorMessage = "Failed to update complaint status: \(error.localizedDescription)"
            }
        }
        
        await loadComplaints(byUnitId: unitId)
        await evaluateButton(unitId: unitId)
        applyFilters()
        
        await createKeyLog(unitId: unitId, userId: userId, detail: "bsc")
    }
    
    
    func rejectKey() {
        showKeyLogAlert = false
    }
    
    private func createKeyLog(unitId: String, userId: String, detail: String) async {
        do {
            _ = try await keyLogService.createKeyLog(unitId: unitId, userId: userId, detail: detail)
            await evaluateButton(unitId: unitId)
        } catch {
            errorMessage = "Failed to create key log: \(error.localizedDescription)"
        }
    }
}
