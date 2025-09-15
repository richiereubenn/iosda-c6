//import Foundation
//
//@MainActor
//class ComplaintListViewModel: ObservableObject {
//    @Published var complaints: [Complaint] = []
//    @Published var filteredComplaints: [Complaint] = []
//    @Published var complaintLogs: [String: [ProgressLog]] = [:] // complaintId -> logs
//
//    @Published var selectedFilter: ComplaintFilter = .open
//    @Published var searchText = ""
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    private let complaintService: ComplaintServiceProtocol
//    private let useMockData = true
//    
//    enum ComplaintFilter: String, CaseIterable {
//        case open = "Open"
//        case inProgress = "In Progress"
//        case resolved = "Resolved"
//        case rejected = "Rejected"
//        
//        var matchingStatusIDs: [String] {
//            switch self {
//            case .open: return [Status.ComplaintStatusID.open.rawValue,
//                                Status.ComplaintStatusID.underReview.rawValue,
//                                Status.ComplaintStatusID.waitingKey.rawValue].compactMap { $0 }
//            case .inProgress: return [Status.ComplaintStatusID.inProgress.rawValue].compactMap { $0 }
//            case .resolved: return [Status.ComplaintStatusID.resolved.rawValue].compactMap { $0 }
//            case .rejected: return [Status.ComplaintStatusID.rejected.rawValue].compactMap { $0 }
//            }
//        }
//    }
//
//    init(complaintService: ComplaintServiceProtocol = ComplaintService()) {
//        self.complaintService = complaintService
//    }
//    
//    func loadComplaints() async {
//        isLoading = true
//        errorMessage = nil
//        
//        if useMockData {
//            loadMockComplaints()
//            filterComplaints()
//            isLoading = false
//            return
//        }
//        
//        do {
//            complaints = try await complaintService.fetchComplaints()
//            filterComplaints()
//        } catch {
//            errorMessage = "Failed to load complaints: \(error.localizedDescription)"
//        }
//        
//        isLoading = false
//    }
//    
//    func logs(for complaintId: String) -> [ProgressLog] {
//         complaintLogs[complaintId] ?? []
//     }
//
//    
//    private func loadMockComplaints() {
//        let formatter = ISO8601DateFormatter()
//        
//        complaints = [
//            Complaint(
//                id: "1",
//                unitId: "1",
//                statusId: "1",
//                progressId: nil,
//                classificationId: nil,
//                title: "Leaky Faucet",
//                description: "Water leaking from kitchen faucet.",
//                openTimestamp: formatter.date(from: "2025-08-20T10:00:00Z"),
//                closeTimestamp: nil,
//                keyHandoverDate: nil,
//                deadlineDate: formatter.date(from: "2025-09-01T00:00:00Z"),
//                latitude: nil,
//                longitude: nil,
//                handoverMethod: .inHouse,
//                unit: Unit(
//                    id: "1",
//                    name: "Northwest Park - NA01/001",
//                    bscUuid: nil,
//                    biUuid: nil,
//                    contractorUuid: nil,
//                    keyUuid: nil,
//                    project: "Citraland Surabaya",
//                    area: "Northwest Park",
//                    block: "NA",
//                    unitNumber: "01/001",
//                    handoverDate: nil,
//                    renovationPermit: false,
//                    isApproved: true
//                ),
//                status: Status(id: "1", name: "open"),
//                classification: nil
//            ),
//            Complaint(
//                id: "4",
//                unitId: "1",
//                statusId: "3",
//                progressId: nil,
//                classificationId: nil,
//                title: "Leaky Faucet",
//                description: "Water leaking from kitchen faucet.",
//                openTimestamp: formatter.date(from: "2025-08-20T10:00:00Z"),
//                closeTimestamp: nil,
//                keyHandoverDate: nil,
//                deadlineDate: formatter.date(from: "2025-09-01T00:00:00Z"),
//                latitude: nil,
//                longitude: nil,
//                handoverMethod: .inHouse,
//                unit: Unit(
//                    id: "1",
//                    name: "Northwest Park - NA01/001",
//                    bscUuid: nil,
//                    biUuid: nil,
//                    contractorUuid: nil,
//                    keyUuid: nil,
//                    project: "Citraland Surabaya",
//                    area: "Northwest Park",
//                    block: "NA",
//                    unitNumber: "01/001",
//                    handoverDate: nil,
//                    renovationPermit: false,
//                    isApproved: true
//                ),
//                status: Status(id: "3", name: "waiting_key"),
//                classification: nil
//            ),
//            Complaint(
//                id: "5",
//                unitId: "1",
//                statusId: "2",
//                progressId: nil,
//                classificationId: nil,
//                title: "Leaky Faucet",
//                description: "Water leaking from kitchen faucet.",
//                openTimestamp: formatter.date(from: "2025-08-20T10:00:00Z"),
//                closeTimestamp: nil,
//                keyHandoverDate: nil,
//                deadlineDate: formatter.date(from: "2025-09-01T00:00:00Z"),
//                latitude: nil,
//                longitude: nil,
//                handoverMethod: .bringToMO,
//                unit: Unit(
//                    id: "1",
//                    name: "Northwest Park - NA01/001",
//                    bscUuid: nil,
//                    biUuid: nil,
//                    contractorUuid: nil,
//                    keyUuid: nil,
//                    project: "Citraland Surabaya",
//                    area: "Northwest Park",
//                    block: "NA",
//                    unitNumber: "01/001",
//                    handoverDate: nil,
//                    renovationPermit: false,
//                    isApproved: true
//                ),
//                status: Status(id: "2", name: "under_review"),
//                classification: nil
//            ),
//            Complaint(
//                id: "2",
//                unitId: "2",
//                statusId: "4",
//                progressId: nil,
//                classificationId: nil,
//                title: "Broken Window",
//                description: "Window shattered after storm.",
//                openTimestamp: formatter.date(from: "2025-08-15T09:00:00Z"),
//                closeTimestamp: nil,
//                keyHandoverDate: nil,
//                deadlineDate: formatter.date(from: "2025-08-30T00:00:00Z"),
//                latitude: nil,
//                longitude: nil,
//                handoverMethod: .bringToMO,
//                unit: Unit(
//                    id: "2",
//                    name: "Northwest Lake - A08/023",
//                    bscUuid: nil,
//                    biUuid: nil,
//                    contractorUuid: nil,
//                    keyUuid: nil,
//                    project: "Citraland Surabaya (North)",
//                    area: "Northwest Lake",
//                    block: "A",
//                    unitNumber: "08/023",
//                    handoverDate: nil,
//                    renovationPermit: true,
//                    isApproved: true
//                ),
//                status: Status(id: "4", name: "in_progress"),
//                classification: nil
//            ),
//            Complaint(
//                id: "3",
//                unitId: "3",
//                statusId: "5",
//                progressId: nil,
//                classificationId: nil,
//                title: "Power Outage",
//                description: "No electricity since yesterday evening.",
//                openTimestamp: formatter.date(from: "2025-07-30T08:00:00Z"),
//                closeTimestamp: formatter.date(from: "2025-08-01T18:00:00Z"),
//                keyHandoverDate: nil,
//                deadlineDate: formatter.date(from: "2025-08-10T00:00:00Z"),
//                latitude: nil,
//                longitude: nil,
//                handoverMethod: .inHouse,
//                unit: Unit(
//                    id: "3",
//                    name: "Bukit Golf - C07/010",
//                    bscUuid: nil,
//                    biUuid: nil,
//                    contractorUuid: nil,
//                    keyUuid: nil,
//                    project: "Citraland Surabaya",
//                    area: "Bukit Golf",
//                    block: "C",
//                    unitNumber: "07/010",
//                    handoverDate: nil,
//                    renovationPermit: false,
//                    isApproved: true
//                ),
//                status: Status(id: "5", name: "resolved"),
//                classification: nil
//            )
//        ]
//        
//        complaintLogs = [
//                "1": [
//                    ProgressLog(
//                        id: "101",
//                        userId: nil,
//                        attachmentId: nil,
//                        title: "Complaint Submitted",
//                        description: "Complaint submitted, waiting for review.",
//                        timestamp: formatter.date(from: "2025-08-20T10:05:00Z"),
//                        files: nil,
//                        progressFiles: nil
//                    ),
//                    ProgressLog(
//                        id: "102",
//                        userId: nil,
//                        attachmentId: nil,
//                        title: "Teknisi Dijadwalkan",
//                        description: "Teknisi akan datang pada 22 Agustus.",
//                        timestamp: formatter.date(from: "2025-08-21T08:00:00Z"),
//                        files: nil,
//                        progressFiles: nil
//                    )
//                ],
//                "4": [
//                    ProgressLog(
//                        id: "201",
//                        userId: nil,
//                        attachmentId: nil,
//                        title: "Complaint Submitted",
//                        description: "Complaint submitted, waiting for review.",
//                        timestamp: formatter.date(from: "2025-08-20T11:00:00Z"),
//                        files: nil,
//                        progressFiles: nil
//                    )
//                ],
//                "5": [
//                    ProgressLog(
//                        id: "301",
//                        userId: nil,
//                        attachmentId: nil,
//                        title: "Complaint Submitted",
//                        description: "Complaint submitted, waiting for review.",
//                        timestamp: formatter.date(from: "2025-08-20T12:00:00Z"),
//                        files: nil,
//                        progressFiles: nil
//                    ),
//                    ProgressLog(
//                        id: "302",
//                        userId: nil,
//                        attachmentId: nil,
//                        title: "Pekerjaan Dimulai",
//                        description: "Teknisi sedang memperbaiki keran bocor.",
//                        timestamp: formatter.date(from: "2025-08-22T09:00:00Z"),
//                        files: nil,
//                        progressFiles: nil
//                    )
//                ],
//                "2": [
//                    ProgressLog(
//                        id: "401",
//                        userId: nil,
//                        attachmentId: nil,
//                        title: "Complaint Submitted",
//                        description: "Complaint submitted, waiting for review.",
//                        timestamp: formatter.date(from: "2025-08-15T09:05:00Z"),
//                        files: nil,
//                        progressFiles: nil
//                    ),
//                    ProgressLog(
//                        id: "402",
//                        userId: nil,
//                        attachmentId: nil,
//                        title: "Material Dipesan",
//                        description: "Bahan pengganti jendela sudah dipesan.",
//                        timestamp: formatter.date(from: "2025-08-16T10:00:00Z"),
//                        files: nil,
//                        progressFiles: nil
//                    )
//                ],
//                "3": [
//                    ProgressLog(
//                        id: "501",
//                        userId: nil,
//                        attachmentId: nil,
//                        title: "Complaint Submitted",
//                        description: "Complaint submitted, waiting for review.",
//                        timestamp: formatter.date(from: "2025-07-30T08:10:00Z"),
//                        files: nil,
//                        progressFiles: nil
//                    ),
//                    ProgressLog(
//                        id: "502",
//                        userId: nil,
//                        attachmentId: nil,
//                        title: "Masalah Terselesaikan",
//                        description: "Listrik sudah kembali normal.",
//                        timestamp: formatter.date(from: "2025-08-01T18:00:00Z"),
//                        files: nil,
//                        progressFiles: nil
//                    )
//                ]
//            ]
//    }
//    
//    func filterComplaints() {
//        filteredComplaints = complaints.filter { complaint in
//            guard let statusId = complaint.status?.id else {
//                return false
//            }
//            return selectedFilter.matchingStatusIDs.contains(statusId)
//        }
//
//        if !searchText.isEmpty {
//            filteredComplaints = filteredComplaints.filter { complaint in
//                complaint.title.localizedCaseInsensitiveContains(searchText) ||
//                complaint.description.localizedCaseInsensitiveContains(searchText) ||
//                (complaint.unit?.name.localizedCaseInsensitiveContains(searchText) ?? false)
//            }
//        }
//    }
//
//
//    
//    func submitComplaint(request: CreateComplaintRequest, selectedUnit: Unit) async throws {
//        if useMockData {
//            let newId = UUID().uuidString
//
//            let newComplaint = Complaint(
//                id: newId,
//                unitId: request.unitId,
//                statusId: Status.ComplaintStatusID.open.rawValue,
//                progressId: nil,
//                classificationId: request.classificationId,
//                title: request.title,
//                description: request.description,
//                openTimestamp: Date(),
//                closeTimestamp: nil,
//                keyHandoverDate: request.keyHandoverDate,
//                deadlineDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
//                latitude: request.latitude,
//                longitude: request.longitude,
//                handoverMethod: Complaint.HandoverMethod(rawValue: request.handoverMethod ?? "") ?? .bringToMO,
//                unit: selectedUnit,
//                status: Status(
//                    id: String(Status.ComplaintStatusID.open.rawValue),
//                    name: Status.ComplaintStatusID.open.apiName
//                ),
//                classification: nil
//            )
//
//            complaints.insert(newComplaint, at: 0)
//
//            let newProgressLog = ProgressLog(
//                id: UUID().uuidString,
//                userId: nil,
//                attachmentId: nil,
//                title: "Complaint Submitted",
//                description: "Complaint submitted, waiting for review.",
//                timestamp: Date(),
//                files: nil,
//                progressFiles: nil
//            )
//
//            complaintLogs[newId] = [newProgressLog]
//            filterComplaints()
//            return
//        }
//
//        _ = try await complaintService.createComplaint(request)
//        await loadComplaints()
//    }
//
//
//    func submitInHouseComplaint(
//        title: String,
//        description: String,
//        unitId: String,
//        handoverMethod: Complaint.HandoverMethod,
//        unitViewModel: UnitViewModel
//    ) async throws {
//        let request = CreateComplaintRequest(
//            unitId: unitId,
//            title: title,
//            description: description,
//            classificationId: nil,
//            keyHandoverDate: nil,
//            latitude: nil,
//            longitude: nil,
//            handoverMethod: handoverMethod.rawValue
//        )
//
//        guard let selectedUnit = unitViewModel.selectedUnit else {
//            throw URLError(.badURL) // Or handle the missing unit however you want
//        }
//        try await submitComplaint(request: request, selectedUnit: selectedUnit)
//
//    }
//
//
//    func logs(for complaint: Complaint) -> [ProgressLog] {
//        guard let id = complaint.id else { return [] }
//        return complaintLogs[id] ?? []
//    }
//
//    
//    func deleteComplaint(at indexSet: IndexSet) async {
//        for index in indexSet {
//            let complaint = filteredComplaints[index]
//            guard let complaintId = complaint.id else { continue }
//            
//            do {
//                try await complaintService.deleteComplaint(id: complaintId)
//                await loadComplaints()
//            } catch {
//                errorMessage = "Failed to delete complaint: \(error.localizedDescription)"
//            }
//        }
//    }
//
//}
