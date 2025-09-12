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
    
    // Menyimpan jumlah complaint per unit
    @Published var complaintsSummary: [String: (total: Int, completed: Int)] = [:]
    
    private let unitService: UnitServiceProtocol2
    private let complaintService: ComplaintServiceProtocol2

    init(
        unitService: UnitServiceProtocol2 = UnitService2(),
        complaintService: ComplaintServiceProtocol2 = ComplaintService2()
    ) {
        self.unitService = unitService
        self.complaintService = complaintService
    }

    func fetchUnits() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await unitService.getUnitsByBSCId()
            self.units = result
            
            // setelah unit didapat, ambil complaint summary
            await getComplaintsSummary(for: result)
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Error fetch units: \(error)")
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
                print("⚠️ Error fetch complaints for unit \(unitId): \(error)")
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
    
    // helper untuk ambil summary
    func getComplaintCounts(for unitId: String) -> (total: Int, completed: Int) {
        complaintsSummary[unitId] ?? (0, 0)
    }
}
