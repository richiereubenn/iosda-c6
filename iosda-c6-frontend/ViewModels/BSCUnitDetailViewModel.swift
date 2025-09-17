//
//  BSCUnitDetailViewModel.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 13/09/25.
//

import Foundation
import SwiftUI

@MainActor
class BSCUnitDetailViewModel: ObservableObject {
    @Published var unit: Unit2?
    @Published var resident: User?
    @Published var unitName: String = "-"
    @Published var blockName: String = "-"
    @Published var areaName: String = "-"
    @Published var projectName: String = "-"
    @Published var isLoading: Bool = false
    
    private let unitService = UnitService2()
    private let userService = UserService()
    private let unitCodeService = UnitCodeService()
    private let blockService = BlockService()
    private let areaService = AreaService()
    private let projectService = ProjectService()
    
    func loadUnit(unitId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetchedUnit = try await unitService.getUnitById(unitId)
            self.unit = fetchedUnit
            await loadUnitHierarchy(unit: fetchedUnit)
            // Load resident
            if let residentId = fetchedUnit.residentId {
                self.resident = try await userService.getUserById(residentId)
            }
            
        } catch {
            print("Failed to load unit: \(error.localizedDescription)")
        }
    }
    
    private func loadUnitHierarchy(unit: Unit2) async {
        do {
            self.unitName = unit.name ?? "-"
            
            guard let unitCodeId = unit.unitCodeId else { return }
            let unitCode = try await unitCodeService.getUnitCodeById(unitCodeId)
            print("Unit code", unitCode)
            let block = try await blockService.getBlockById(unitCode.blockId)
            let area = try await areaService.getAreaById(block.areaId)
            let project = try await projectService.getProjectById(area.projectId)
            
            self.blockName = block.name
            self.areaName = area.name
            self.projectName = project.name
        } catch {
            print("Failed to load hierarchy: \(error.localizedDescription)")
        }
    }
    
    func confirmUnit(unitId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let bscId = NetworkManager.shared.getUserIdFromToken() else {
                print("No BSC ID found in token")
                return
            }
            
            let updatedUnit = try await unitService.updateUnit(unitId: unitId, bscId: bscId)
            self.unit = updatedUnit
            print("Unit berhasil dikonfirmasi: \(updatedUnit)")
            
        } catch {
            print("Gagal mengupdate unit: \(error.localizedDescription)")
        }
    }

}

