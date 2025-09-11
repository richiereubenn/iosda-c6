import SwiftUI

struct ResidentComplaintDetailView: View {
    
    let complaint: Complaint2
    let complaintListViewModel: ComplaintListViewModel2?
    
    @Environment(\.dismiss) var dismiss
    @State private var showingImageViewer = false
    @State private var selectedImageIndex = 0
    @State private var showingProgressDetail = false
    
    init(complaint: Complaint2, complaintListViewModel: ComplaintListViewModel2? = nil) {
        self.complaint = complaint
        self.complaintListViewModel = complaintListViewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(complaint.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    // 2. Compare handoverMethod with a String value now
                    if complaint.handoverMethod == "bring_to_mo" {
                        if let handoverDate = complaint.keyHandoverDate {
                            HStack(spacing: 6) {
                                Text("Key Handover Date:")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Text(formatDate(handoverDate))
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // MARK: - Status Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 12) {
                        Text("Status")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // 3. Use statusName to determine the status for the badge
                        StatusBadge(status: ComplaintStatus(raw: complaint.statusName))
                        
                        Spacer()
                        
                        Button("See Detail") {
                            showingProgressDetail = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    // Note: StatusProgressBar may need to be updated to accept a String
                    StatusProgressBar(currentStatusName: complaint.statusName)
                }
                .padding(.horizontal, 20)
                
                // 2. Compare handoverMethod with a String value
                if complaint.handoverMethod == "in_house" {
                    if let openDate = complaint.openTimestamp {
                        let estimatedVisitDate = Calendar.current.date(byAdding: .day, value: 3, to: openDate)!
                        
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "info.circle.fill")
                            
                            Text("BSC will come to your house soon, no later than ")
                                .foregroundColor(.primary)
                            +
                            Text(formatDate(estimatedVisitDate))
                                .bold()
                        }
                        .font(.subheadline)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                    }
                }
                
                // MARK: - Detail Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detail")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // 4. Use flattened properties from the Complaint2 model
                        DetailRow(label: "ID", value: "#\(complaint.id)")
                        DetailRow(label: "Complain Type", value: complaint.classificationName ?? "Unknown")
                        DetailRow(label: "Created", value: formatDateWithTime(complaint.openTimestamp ?? Date()))
                        
                        // IMPORTANT: Complaint2 only has unitId, not full unit details.
                        // You will need a way to fetch unit details based on this ID.
                        // For now, we'll just display the ID.
                        if let unitId = complaint.unitId {
                            DetailRow(label: "Unit ID", value: unitId)
                        }
                        
                        if let closeTimestamp = complaint.closeTimestamp {
                            DetailRow(label: "Closed", value: formatDateWithTime(closeTimestamp))
                        }
                    }
                    
                    // Placeholder for images
                    
                    if !complaint.description.isEmpty {
                        Text(complaint.description)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showingProgressDetail) {
            // Updated to use the new ViewModel type
            ResidentProgressDetailView(
                complaintId: complaint.id, complaintListViewModel: ComplaintListViewModel2()
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .overlay(alignment: .bottom) {
            // 5. Update status check logic to use statusName string
            if let status = complaint.statusName?.lowercased(),
               let method = complaint.handoverMethod,
               (status == "in progress" || status == "waiting key") && method == "bring_to_mo" {
                VStack(spacing: 0) {
                    CustomButtonComponent(
                        text: "Submit Key Handover Evidence",
                        action: { /* Handle submit key handover evidence */ }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .background(Color(.systemBackground))
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    private func formatDateWithTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy; HH:mm"
        return formatter.string(from: date)
    }
}

// DetailRow remains the same, it's a good reusable component.
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.body)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ResidentComplaintDetailView(
            // Use the new Complaint2 model for the preview
            complaint: Complaint2(
                id: "2b4c59bd-0460-426b-a720-80ccd85ed5b2",
                unitId: "u-12345",
                userId: "user-67890",
                statusId: "s-4",
                classificationId: "c-1",
                title: "Leaking Faucet in Kitchen",
                description: "The main kitchen faucet has been dripping constantly for the past two days, wasting water.",
                openTimestamp: Date(),
                closeTimestamp: nil,
                keyHandoverDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
                deadlineDate: Date(),
                latitude: nil,
                longitude: nil,
                handoverMethod: "in_house",
                workDetail: nil,
                workDuration: nil,
                createdAt: Date(),
                updatedAt: Date(),
                statusName: "In Progress",
                classificationName: "Plumbing"
            ),
            // Use the new ComplaintListViewModel2 for the preview
            complaintListViewModel: ComplaintListViewModel2()
        )
    }
}
