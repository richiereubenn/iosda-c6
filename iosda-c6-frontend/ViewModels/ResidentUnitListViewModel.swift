
import Foundation
import Combine
@MainActor
class ResidentUnitListViewModel: ObservableObject {
    @Published var claimedUnits: [Unit2] = []
    @Published var waitingUnits: [Unit2] = []
    @Published var selectedUnit: Unit2? = nil
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Cache
    private var unitCodesById: [String: UnitCode] = [:]
    private var blocksById: [String: Block] = [:]
    private var areasById: [String: Area] = [:]
    private var projectsById: [String: Project] = [:]
    
    private let unitService: UnitServiceProtocol2
    private let unitCodeService: UnitCodeServiceProtocol
    private let blockService: BlockServiceProtocol
    private let areaService: AreaServiceProtocol
    private let projectService: ProjectServiceProtocol
    
    
    init(
        unitService: UnitServiceProtocol2 = UnitService2(),
        unitCodeService: UnitCodeServiceProtocol = UnitCodeService(),
        blockService: BlockServiceProtocol = BlockService(),
        areaService: AreaServiceProtocol = AreaService(),
        projectService: ProjectServiceProtocol = ProjectService()
    ) {
        self.unitService = unitService
        self.unitCodeService = unitCodeService
        self.blockService = blockService
        self.areaService = areaService
        self.projectService = projectService
    }
    
    var residentId: String? {
        return NetworkManager.shared.getUserIdFromToken()
    }
    
    func getUnitById(_ id: String) async throws -> Unit2 {
        return try await unitService.getUnitById(id)
    }
    
    func loadUnits() async {
        guard let residentId = residentId else {
            errorMessage = "User not logged in"
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let units = try await unitService.getUnitsByResidentId(residentId: residentId)
            print("Loaded units:", units)
            
            // Filter claimed and waiting units
            self.claimedUnits = units.filter {
                !($0.bscId?.isEmpty ?? true)  // bscId must be non-empty
            }
            self.waitingUnits = units.filter {
                ($0.bscId?.isEmpty ?? true)
            }
            
            print("Claimed units count: \(claimedUnits.count)")
            print("Waiting units count: \(waitingUnits.count)")
            
            
            // Load related data to resolve project names
            await loadRelatedData(for: units)
            
            isLoading = false
        } catch {
            errorMessage = "Failed to load units: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func loadRelatedData(for units: [Unit2]) async {
        let unitCodeIds = Set(units.compactMap { $0.unitCodeId })
        for id in unitCodeIds where unitCodesById[id] == nil {
            if let unitCode = try? await unitCodeService.getUnitCodeById(id) {
                unitCodesById[id] = unitCode
            }
        }
        
        let blockIds = Set(unitCodesById.values.compactMap { $0.blockId })
        for id in blockIds where blocksById[id] == nil {
            if let block = try? await blockService.getBlockById(id) {
                blocksById[id] = block
            }
        }
        
        let areaIds = Set(blocksById.values.compactMap { $0.areaId })
        for id in areaIds where areasById[id] == nil {
            if let area = try? await areaService.getAreaById(id) {
                areasById[id] = area
            }
        }
        
        let projectIds = Set(areasById.values.compactMap { $0.projectId })
        for id in projectIds where projectsById[id] == nil {
            if let project = try? await projectService.getProjectById(id) {
                projectsById[id] = project
            }
        }
    }
    
    func getProjectName(for unit: Unit2) -> String? {
        guard
            let unitCodeId = unit.unitCodeId,
            let unitCode = unitCodesById[unitCodeId],
            let block = blocksById[unitCode.blockId],
            let area = areasById[block.areaId],
            let project = projectsById[area.projectId]
        else { return nil }
        return project.name
    }
    
    func updateKeyHandoverDate(unitId: String, keyDate: Date, note: String?) async throws {
        // Log to check which unitId is being passed in
        print("Updating key handover date for unitId: \(unitId)")
        
        print("Claimed units: \(claimedUnits)")
        // Find the unit in the claimedUnits array
        guard let index = claimedUnits.firstIndex(where: { $0.id == unitId }) else {
            print("Unit with ID \(unitId) not found in claimedUnits.")
            throw NSError(domain: "Unit not found", code: 404, userInfo: nil)
        }
        
        // Retrieve the unit from the list
        var unit = claimedUnits[index]
        
        print("Found unit: \(unit)") // Log the unit found
        
        // Call the updateUnit method from UnitService2 to update the key handover date and note
        do {
            let updatedUnit = try await unitService.updateUnitKey(unit, keyDate: keyDate, note: note ?? "")
            
            // Update local copy after success
            claimedUnits[index] = updatedUnit
            print("Successfully updated unit: \(updatedUnit)") // Log successful update
        } catch {
            // Handle the error if update fails
            print("Error updating unit: \(error.localizedDescription)") // Log error
            throw NSError(domain: "Failed to update unit", code: 500, userInfo: [NSLocalizedDescriptionKey: "Error: \(error.localizedDescription)"])
        }
    }
    
    func resetKeyHandoverDate(unitId: String) async throws {
        guard let index = claimedUnits.firstIndex(where: { $0.id == unitId }) else {
            throw NSError(domain: "Unit not found", code: 404, userInfo: nil)
        }
        
        var unit = claimedUnits[index]
        
        let updatedUnit = try await unitService.updateUnitKeyOptional(unit, keyDate: nil, note: nil)
        claimedUnits[index] = updatedUnit
    }

    
}
