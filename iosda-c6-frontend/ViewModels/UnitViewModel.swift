import Foundation

@MainActor
class UnitViewModel: ObservableObject {
    @Published var units: [Unit] = []
    @Published var userUnits: [UserUnit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddUnit = false
    @Published var selectedSegment = 0
    @Published var selectedUnit: Unit?

    
    private let useMockData = true
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
        if useMockData {
              loadMockData()
             // selectedUnit = claimedUnits.first
              return
          }
        
        
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
        if useMockData {
            // Mock: Add unit to waiting list
            let newUnitId = Int.random(in: 1000...9999)
            
            let newUnit = Unit(
                id: newUnitId,
                name: name,
                bscUuid: nil,
                biUuid: nil,
                contractorUuid: nil,
                keyUuid: nil,
                project: project,
                area: area,
                block: block,
                unitNumber: unitNumber,
                handoverDate: handoverDate,
                renovationPermit: renovationPermit,
                //ownershipType: ownershipType,
                isApproved: false // Always goes to waiting first
            )
            
            units.append(newUnit)
            
            let userUnit = UserUnit(
                id: nil,
                userId: nil ,
                unitId: newUnitId,
                ownershipType: ownershipType
            )
            userUnits.append(userUnit)
            
            showingAddUnit = false
            return
        }
        
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
        if useMockData {
            units.removeAll { $0.id == unit.id }
            return
        }
        
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
    private func loadMockData() {
        units = [
            // Claimed units (approved)
            Unit(
                id: 1,
                name: "Northwest Park - NA01/001",
                bscUuid: nil,
                biUuid: nil,
                contractorUuid: nil,
                keyUuid: nil,
                project: "Citraland Surabaya",
                area: "Northwest Park",
                block: "NA",
                unitNumber: "01/001",
                handoverDate: nil,
                renovationPermit: false,
                //ownershipType: "Owner",
                isApproved: true
            ),
            Unit(
                id: 2,
                name: "Northwest Lake - A08/023",
                bscUuid: nil,
                biUuid: nil,
                contractorUuid: nil,
                keyUuid: nil,
                project: "Citraland Surabaya (North)",
                area: "Northwest Lake",
                block: "A",
                unitNumber: "08/023",
                handoverDate: nil,
                renovationPermit: true,
                //ownershipType: "Family",
                isApproved: true
            ),
            Unit(
                id: 3,
                name: "Bukit Golf - C07/010",
                bscUuid: nil,
                biUuid: nil,
                contractorUuid: nil,
                keyUuid: nil,
                project: "Citraland Surabaya",
                area: "Bukit Golf",
                block: "C",
                unitNumber: "07/010",
                handoverDate: nil,
                renovationPermit: false,
                //ownershipType: "Owner",
                isApproved: true
            ),
            
            // Waiting units (not approved)
            Unit(
                id: 4,
                name: "Northwest Park - ND09/033",
                bscUuid: nil,
                biUuid: nil,
                contractorUuid: nil,
                keyUuid: nil,
                project: "Citraland Surabaya (North)",
                area: "Northwest Park",
                block: "ND",
                unitNumber: "09/033",
                handoverDate: nil,
                renovationPermit: false,
                //ownershipType: "Others",
                isApproved: false
            ),
            Unit(
                id: 5,
                name: "Diamond Hill - B01/003",
                bscUuid: nil,
                biUuid: nil,
                contractorUuid: nil,
                keyUuid: nil,
                project: "Citraland Surabaya",
                area: "Diamond Hill",
                block: "B",
                unitNumber: "01/003",
                handoverDate: nil,
                renovationPermit: false,
                //ownershipType: "Family",
                isApproved: false
            )
        ]
        userUnits = [
            UserUnit(id: nil, userId: nil, unitId: 1, ownershipType: "Owner"),
            UserUnit(id: nil, userId: nil, unitId: 2, ownershipType: "Family"),
            UserUnit(id: nil, userId: nil, unitId: 3, ownershipType: "Owner"),
            UserUnit(id: nil, userId: nil, unitId: 4, ownershipType: "Others"),
            UserUnit(id: nil, userId: nil, unitId: 5, ownershipType: "Family")
        ]
        if self.selectedUnit == nil {
                self.selectedUnit = claimedUnits.first
            }

    }
}
