//
//  BSCBuildingUnitComplainListViewModel 2.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 13/09/25.
//

import Foundation

@MainActor
class BIHomepageViewModel: ObservableObject {
    @Published var units: [Unit2] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var totalActiveUnits: Int = 0
    @Published var totalActiveComplaints: Int = 0
    
    @Published var complaintsSummary: [String: (total: Int, completed: Int)] = [:]
    
    private let unitService: UnitServiceProtocol2
    private let complaintService: ComplaintServiceProtocol2
    private let networkManager: NetworkManager
    
    init(
        unitService: UnitServiceProtocol2 = UnitService2(),
        complaintService: ComplaintServiceProtocol2 = ComplaintService2(),
        networkManager: NetworkManager = .shared
    ) {
        self.unitService = unitService
        self.complaintService = complaintService
        self.networkManager = networkManager
    }
    
    func fetchUnits() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await unitService.getUnitsByBIId()
            self.units = result
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
            let units = try await unitService.getUnitsByBIId()
            print("Units fetched for summary: \(units.count)")
            
            var activeComplaintsCount = 0
            var activeUnitIds: Set<String> = []
            
            for unit in units {
                let complaints = try await complaintService.getComplaintsByUnitId(unit.id)
                print("Unit \(unit.id) complaints: \(complaints.count)")
                
                let activeComplaints = complaints.filter { isActiveComplaint($0) }
                print("Active complaints: \(activeComplaints.count)")
                
                if !activeComplaints.isEmpty {
                    activeComplaintsCount += activeComplaints.count
                    activeUnitIds.insert(unit.id)
                }
            }
            
            self.totalActiveComplaints = activeComplaintsCount
            self.totalActiveUnits = activeUnitIds.count
            
            print("Summary → Units: \(self.totalActiveUnits), Complaints: \(self.totalActiveComplaints)")
        } catch {
            print("Error fetching summary: \(error)")
            self.totalActiveUnits = 0
            self.totalActiveComplaints = 0
        }
    }


    
    private func isActiveComplaint(_ complaint: Complaint2) -> Bool {
        let status = complaint.statusName?.lowercased() ?? ""
        return status != "resolved" && status != "rejected"
    }
}
