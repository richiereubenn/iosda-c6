//
//  UnitViewModel.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 31/08/25.
//
import Foundation

@MainActor
class UnitViewModel: ObservableObject {
    @Published var units: [Unit] = []
    @Published var userUnits: [UserUnit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddUnit = false
    @Published var selectedSegment = 0
    
    private let service = UnitService()
    
    var waitingUnits: [Unit] {
        units.filter { $0.isApproved != true }
    }
    
    var claimedUnits: [Unit] {
        units.filter { $0.isApproved == true }
    }
    
    var filteredUnits: [Unit] {
        selectedSegment == 0 ? claimedUnits : waitingUnits
    }
    
    func getUserUnit(for unit: Unit) -> UserUnit? {
        return userUnits.first(where: { $0.unitId == unit.id })
    }

    
    func searchUnits(with searchText: String) -> [Unit] {
        if searchText.isEmpty {
            return filteredUnits
        } else {
            return filteredUnits.filter { unit in
                unit.name.localizedCaseInsensitiveContains(searchText) ||
                unit.area?.localizedCaseInsensitiveContains(searchText) == true ||
                unit.project?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    
    func loadUnits() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                units = try await service.fetchUnits()
            } catch {
                errorMessage = "Failed to load units: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    func addUnit(name: String, project: String?, area: String?, block: String?, unitNumber: String?, handoverDate: Date?, renovationPermit: Bool, ownershipType: String?) {
        Task {
            isLoading = true
            errorMessage = nil
            
            let request = CreateUnitRequest(
                name: name,
                project: project,
                area: area,
                block: block,
                unitNumber: unitNumber,
                handoverDate: handoverDate,
                renovationPermit: renovationPermit,
                ownershipType: ownershipType
            )
            
            do {
                let newUnit = try await service.createUnit(request)
                units.append(newUnit)
                showingAddUnit = false
            } catch {
                errorMessage = "Failed to create unit: \(error.localizedDescription)"
            }
            
            isLoading = false
        }
    }
    
    func deleteUnit(_ unit: Unit) {
        guard let id = unit.id else { return }
        
        Task {
            do {
                try await service.deleteUnit(id: id)
                units.removeAll { $0.id == id }
            } catch {
                errorMessage = "Failed to delete unit: \(error.localizedDescription)"
            }
        }
    }
}
