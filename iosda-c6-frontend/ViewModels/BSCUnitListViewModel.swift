//
//  BSCUnitListViewModel.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 13/09/25.
//

import Foundation
import SwiftUI

@MainActor
class BSCUnitListViewModel: ObservableObject {
    @Published var units: [Unit2] = []
    @Published var filteredUnits: [Unit2] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedSegment: Int = 0 // 0 = All, 1 = Pending, 2 = Approved
    @Published var users: [String: User] = [:] // Cache resident data
    
    private let unitService = UnitService2()
    private let userService = UserService()
    
    var waitingUnits: [Unit2] {
        units.filter { $0.bscId == nil }
    }
    
    var approvedUnits: [Unit2] {
        units.filter { $0.bscId != nil }
    }
    
    func loadUnits() {
        Task {
            await fetchUnits()
        }
    }
    
    private func fetchUnits() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let allUnits = try await unitService.getAllUnits()
            self.units = allUnits
            await fetchResidentData(for: allUnits)
            filterUnits()
        } catch {
            errorMessage = "Failed to load units: \(error.localizedDescription)"
        }
    }
    
    private func fetchResidentData(for units: [Unit2]) async {
        for unit in units {
            if let residentId = unit.residentId, users[residentId] == nil {
                do {
                    let user = try await userService.getUserById(residentId)
                    users[residentId] = user
                } catch {
                    print("Failed to load resident \(residentId): \(error.localizedDescription)")
                }
            }
        }
    }
    
    func filterUnits(searchText: String = "") {
        var tempUnits = units
        
        // Filter by segmented control
        switch selectedSegment {
        case 1:
            tempUnits = tempUnits.filter { $0.bscId == nil } // pending
        case 2:
            tempUnits = tempUnits.filter { $0.bscId != nil } // approved
        default:
            break
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            tempUnits = tempUnits.filter {
                $0.name!.localizedCaseInsensitiveContains(searchText) ||
                $0.unitNumber?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        self.filteredUnits = tempUnits
    }
    
    func getUser(for unit: Unit2) -> User? {
        guard let residentId = unit.residentId else { return nil }
        return users[residentId]
    }
    
    func acceptUnit(_ unit: Unit2) {
        if let index = units.firstIndex(where: { $0.id == unit.id }) {
            /*units[index].bscId = "approved"*/ // contoh update status
            filterUnits()
        }
    }
    
    func rejectUnit(_ unit: Unit2) {
        if let index = units.firstIndex(where: { $0.id == unit.id }) {
            units.remove(at: index)
            filterUnits()
        }
    }
}
