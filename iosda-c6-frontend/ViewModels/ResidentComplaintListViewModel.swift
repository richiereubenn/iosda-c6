
import Foundation
import SwiftUI

@MainActor
class ResidentComplaintListViewModel: ObservableObject {
    @Published var complaints: [Complaint2] = []
    @Published var filteredComplaints: [Complaint2] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var unitNames: [String: String] = [:]   // unitId → unitName

    
    @Published var selectedFilter: ComplaintFilter = .all {
        didSet { applyFilters() }
    }
    @Published var searchText: String = "" {
        didSet { applyFilters() }
    }
    
    private let service: ComplaintServiceProtocol2
    private let unitService: UnitServiceProtocol2
    
    init(service: ComplaintServiceProtocol2 = ComplaintService2(),
    unitService: UnitServiceProtocol2 = UnitService2()) {
        self.service = service
        self.unitService = unitService
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
                
                for complaint in complaints {
                            if let unitId = complaint.unitId, unitNames[unitId] == nil {
                                Task {
                                    if let unit = try? await unitService.getUnitById(unitId) {
                                        await MainActor.run {
                                            self.unitNames[unitId] = unit.name ?? "Unknown Unit"
                                        }
                                    }
                                }
                            }
                        }
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
    
    func isHandoverMethodLocked(for unitId: String) -> Bool {
           let inProgressStatuses = [
               "waiting key handover",
               "under review by bi",
               "in progress",
               "assign to vendor"
           ]

           return complaints.contains {
               $0.unitId == unitId &&
               inProgressStatuses.contains($0.statusName?.lowercased() ?? "")
           }
       }
    
    private func applyFilters() {
        var results = complaints

        switch selectedFilter {
        case .all:
            break
        case .underReview:
            results = results.filter {
                let status = $0.statusName?.lowercased() ?? ""
                return status == "under review by bsc"
            }
        case .inProgress:
            results = results.filter {
                let status = $0.statusName?.lowercased() ?? ""
                return status == "waiting key handover" ||
                       status == "under review by bi" ||
                       status == "in progress" ||
                       status == "assign to vendor"
            }
        case .done:
            results = results.filter {
                let status = $0.statusName?.lowercased() ?? ""
                return status == "resolved" || status == "rejected"
            }
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
        case underReview = "Under Review"
        case inProgress = "In Progress"
        case done = "Done"
    }
    
    func resolveHandoverConflict(unitId: String, newMethod: HandoverMethod) async {
        // 1. Update complaints
        let conflicts = complaints.filter {
            $0.unitId == unitId &&
            $0.statusName?.lowercased() == "under review by bsc" &&
            $0.handoverMethod != newMethod
        }

        for conflict in conflicts {
            do {
                let updated = try await service.updateComplaintHandoverMethod(
                    complaintId: conflict.id,
                    newMethod: newMethod
                )
                if let index = complaints.firstIndex(where: { $0.id == conflict.id }) {
                    complaints[index] = updated
                }
            } catch {
                print("Failed to update complaint \(conflict.id): \(error)")
            }
        }
        // 2. Reset unit key handover date
        do {
            let unit = try await unitService.getUnitById(unitId)
            _ = try await unitService.updateUnitKeyOptional(unit, keyDate: nil, note: nil)
            print("Successfully reset key handover date for unit \(unitId)")
        } catch {
            print("Failed to reset key handover date for unit \(unitId): \(error)")
        }

    }
    
    func updateUnitKeyDate(unitId: String, newKeyDate: Date?) async {
        do {
            // Get the unit first
            let unit = try await unitService.getUnitById(unitId)
            
            // Update the unit's key handover date
            let updatedUnit = try await unitService.updateUnitKeyOptional(
                unit,
                keyDate: newKeyDate,
                note: nil
            )
            
            print("Successfully updated unit key date for unit \(unitId)")
            print("New key date: \(String(describing: newKeyDate))")
            
        } catch {
            print("Failed to update unit key date for unit \(unitId): \(error)")
            errorMessage = "Failed to update key handover date: \(error.localizedDescription)"
        }
    }
}
