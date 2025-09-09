import Foundation

@MainActor
class ComplaintDetailViewModel: ObservableObject {
    @Published var progressLogs: [ProgressLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let complaintService: ComplaintServiceProtocol2
    
    init(complaintService: ComplaintServiceProtocol2 = ComplaintService2()) {
        self.complaintService = complaintService
    }

    func getProgressLogs(complaintId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            print("Fetching logs for complaintId: \(complaintId)")
            let logs = try await complaintService.getProgressLogs(complaintId: complaintId)
            print("Fetched \(logs.count) logs")
            progressLogs = logs
        } catch {
            errorMessage = "Failed to load progress logs: \(error.localizedDescription)"
            print(errorMessage ?? "Unknown error")
        }
        
        isLoading = false
    }

}
