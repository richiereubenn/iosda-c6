//
//  BSCBuildingUnitComplainListViewModel 2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 13/09/25.
//

import Foundation

@MainActor
class BSCBuildingUnitComplainListViewModel: ObservableObject {
    @Published var units: [Unit2] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var totalActiveUnits: Int = 0
    @Published var totalActiveComplaints: Int = 0
    
    // Menyimpan jumlah complaint per unit
    @Published var complaintsSummary: [String: (total: Int, completed: Int)] = [:]
    
    
    private let unitService: UnitServiceProtocol2
    let complaintService: ComplaintServiceProtocol2
    let classificationService: ClassificationServiceProtocol
    
    init(
        unitService: UnitServiceProtocol2 = UnitService2(),
        complaintService: ComplaintServiceProtocol2 = ComplaintService2(),
        classificationService: ClassificationServiceProtocol = ClassificationService()
    ) {
        self.unitService = unitService
        self.complaintService = complaintService
        self.classificationService = classificationService
    }
    
    func fetchUnits() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await unitService.getUnitsByBSCId()
            self.units = result
            
            await checkWarrantyAndRenovation(for: result)
            await getComplaintsSummary(for: result)
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func getComplaintsSummary(for units: [Unit2]) async {
        for unit in units {
            let unitId = unit.id
            do {
                let complaints = try await complaintService.getComplaintsByUnitId(unitId)
                let total = complaints.count
                let completed = complaints.filter { complaint in
                    let status = complaint.statusName?.lowercased() ?? ""
                    return status == "resolved" || status == "rejected"
                }.count
                
                complaintsSummary[unitId] = (total, completed)
            } catch {
                complaintsSummary[unitId] = (0, 0)
            }
        }
    }
    
    func getFilteredAndSortedUnits() -> [Unit2] {
        if searchText.isEmpty {
            return units
        } else {
            return units.filter { unit in
                unit.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    func getComplaintCounts(for unitId: String) -> (total: Int, completed: Int) {
        complaintsSummary[unitId] ?? (0, 0)
    }
    
    func fetchSummary() async {
        do {
            let units = try await unitService.getUnitsByBSCId()
            
            var activeComplaintsCount = 0
            var activeUnitIds: Set<String> = []
            
            for unit in units {
                let complaints = try await complaintService.getComplaintsByUnitId(unit.id)
                
                let activeComplaints = complaints.filter { isActiveComplaint($0) }
                
                if !activeComplaints.isEmpty {
                    activeComplaintsCount += activeComplaints.count
                    activeUnitIds.insert(unit.id)
                }
            }
            
            self.totalActiveComplaints = activeComplaintsCount
            self.totalActiveUnits = activeUnitIds.count
            
        } catch {
            self.totalActiveUnits = 0
            self.totalActiveComplaints = 0
        }
    }
    
    
    private func isActiveComplaint(_ complaint: Complaint2) -> Bool {
        let status = complaint.statusName?.lowercased() ?? ""
        return status != "resolved" && status != "rejected"
    }
    
    private func checkWarrantyAndRenovation(for units: [Unit2]) async {
        for unit in units {
            do {
                let complaints = try await complaintService.getComplaintsByUnitId(unit.id)
                for complaint in complaints {
                    var classification: Classification? = nil
                    if let classificationId = complaint.classificationId {
                        classification = try? await classificationService.getClassificationById(classificationId)
                    }
                    
                    let warrantyValid = isWarrantyValid(for: complaint, unit: unit, classification: classification)
                    let renovationValid = unit.renovationPermit ?? false
                    
                    if !warrantyValid || !renovationValid {
                        // Update status complaint jadi rejected
                        try await complaintService.updateComplaintStatus(
                            complaintId: complaint.id,
                            statusId: "99d06c4a-e49f-4144-b617-2a1b6c51092f" // rejected
                        )
                    }
                }
            } catch {
                print("Failed to check warranty/renovation: \(error.localizedDescription)")
            }
        }
    }
    
    func isWarrantyValid(for complaint: Complaint2, unit: Unit2?, classification: Classification?) -> Bool {
        guard let unit = unit, let handoverDate = unit.handoverDate, let complaintDate = complaint.createdAt else { return false }
        
        let calendar = Calendar.current
        let monthsToAdd: Int
        if classification?.workDetail?.lowercased() == "atap bocor" {
            monthsToAdd = 12
        } else {
            monthsToAdd = 3
        }
        
        if let warrantyEndDate = calendar.date(byAdding: .month, value: monthsToAdd, to: handoverDate) {
            return complaintDate <= warrantyEndDate
        }
        
        return false
    }
}
