//
//  AddUnitViewModel.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 13/09/25.
//
import SwiftUI
import Foundation

@MainActor
class AddUnitViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var residentId: String = ""
    @Published var bscId: String? = nil
    @Published var biId: String? = nil
    
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var areaName: String = ""
    @Published var unitCodeName: String = ""
    @Published var unitCodeId: String = ""
    @Published var didFail: Bool = false
    
    
    private let unitService: UnitService2
    
    init(unitService: UnitService2 = UnitService2()) {
        self.unitService = unitService
        self.loadResidentId()
    }
    
    private func loadResidentId() {
        if let userId = NetworkManager.shared.getUserIdFromToken() {
            residentId = userId
            print("Resident ID loaded: \(residentId)")
        } else {
            print("Failed to load resident ID")
        }
    }
    
    var isFormValid: Bool {
        !name.isEmpty && !residentId.isEmpty
        // bscId and biId are optional, so no need to validate here
    }
    
    func submitUnitClaim(onSuccess: @escaping () -> Void) async {
        
        loadResidentId()
        
        guard !residentId.isEmpty else {
               errorMessage = "User is not logged in."
               return
           }
        
        print("🔹 Submitting unit claim...")
        print("📦 Constructed name: \(areaName) - \(unitCodeName)")
        print("👤 residentId: \(residentId)")
        print("🏷️ unitCodeId: \(unitCodeId)")
        
        guard !areaName.isEmpty, !unitCodeName.isEmpty, !residentId.isEmpty else {
            errorMessage = "Please fill in all required fields."
            return
        }
        
        let constructedName = "\(areaName) - \(unitCodeName)"
        self.name = constructedName
        let unitNumber = unitCodeName
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        didFail = false
        
        do {
            let createdUnit = try await unitService.createUnit(
                name: constructedName,
                resident_id: residentId,
                bsc_id: bscId,
                bi_id: biId,
                unitCode_id: unitCodeId,
                unit_number: unitNumber
            )
            
            successMessage = "Unit claim submitted successfully: \(createdUnit.name ?? "")"
            onSuccess()
            
        } catch {
            let nsError = error as NSError
            let message = nsError.localizedDescription.lowercased()

            if message.contains("duplicate") || message.contains("conflict") {
                errorMessage = "This unit has already been claimed or is currently in the process of being claimed."
            } else {
                //to be changed
//                errorMessage = "Failed to submit unit claim: \(error.localizedDescription)"
                
                errorMessage = "This unit has already been claimed or is currently in the process of being claimed."
            }

            didFail = true
        }
        
        isLoading = false
    }
}
