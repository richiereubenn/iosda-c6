import SwiftUI

struct ResidentComplaintDetailView: View {
    let complaint: Complaint
    let complaintListViewModel: ComplaintListViewModel?
    @Environment(\.dismiss) var dismiss
    @State private var showingImageViewer = false
    @State private var selectedImageIndex = 0
    @State private var showingProgressDetail = false
    
    
    init(complaint: Complaint, complaintListViewModel: ComplaintListViewModel? = nil) {
        self.complaint = complaint
        self.complaintListViewModel = complaintListViewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with title and estimation
                VStack(alignment: .leading, spacing: 8) {
                    Text(complaint.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    if complaint.handoverMethod == .bringToMO{
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
                
                // Status Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 12) {
                        Text("Status")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let statusID = complaint.status?.complaintStatusID {
                            StatusBadge(statusID: statusID)
                        }
                        Spacer()
                        
                        Button("See Detail") {
                            showingProgressDetail = true
                        }
                        
                        .foregroundColor(.blue)
                        .font(.body)
                    }
                    
                    // Status Progress Indicator
                    StatusProgressBar(currentStatus: complaint.status)
                }
                .padding(.horizontal, 20)
                
                if complaint.handoverMethod == .inHouse {
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
                
                
                // Detail Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detail")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        DetailRow(label: "ID", value: "#\(complaint.id ?? "")")

                        DetailRow(label: "Complain Type", value: complaint.classification?.name ?? "Unknown")
                        DetailRow(label: "Created", value: formatDateWithTime(complaint.openTimestamp ?? Date()))
                        
                        if let unit = complaint.unit {
                            DetailRow(label: "Unit", value: unit.name)
                        }
                        
                        if let closeTimestamp = complaint.closeTimestamp {
                            DetailRow(label: "Closed", value: formatDateWithTime(closeTimestamp))
                        }
                    }
                    
                    // PLACEHOLDER IMAGE
                    HStack (spacing: 0){
                        VStack(spacing: 12) {
                            Spacer()
                                .frame(height: 20)
                            
                            
                            Text ("Placeholder Image")
                                .font(.subheadline)
                            
                            Spacer()
                                .frame(height: 20)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                        //.padding(.horizontal)
                        Spacer()
                        VStack(spacing: 12) {
                            Spacer()
                                .frame(height: 20)
                            
                            Text( "Placeholder Image")
                                .font(.subheadline)
                            
                            Spacer()
                                .frame(height: 20)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                        //.padding(.horizontal)
                        
                    }
                    // Description
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
            
            ProgressDetailView(
                complaintId: complaint.id ?? "",
                complaintListViewModel: complaintListViewModel
            )

        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.body)
                            .fontWeight(.medium)
                        Text("Home")
                            .font(.body)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        
        .overlay(alignment: .bottom) {
            if let statusID = complaint.status?.complaintStatusID,
               (statusID == .inProgress || statusID == .waitingKey),
               complaint.handoverMethod == .bringToMO {
                VStack(spacing: 0) {
                    CustomButtonComponent(
                        text: "Submit Key Handover Evidence",
                        action: {
                            // Handle submit key handover evidence
                        }
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
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formatDateWithTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy; HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label) :")
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
            complaint: Complaint(
                id: "26082025002",
                unitId: "1",
                // ✅ FIX: Make these two lines consistent!
                statusId: "4",
                progressId: nil,
                classificationId: "1",
                title: "Anjing Masuk Rumah",
                description: "when an unknown printer took a galley of type and scrambled it to make a type specimen book...",
                openTimestamp: Date(),
                closeTimestamp: nil,
                keyHandoverDate: Calendar.current.date(byAdding: .day, value: 18, to: Date()),
                deadlineDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()),
                latitude: nil,
                longitude: nil,
                handoverMethod: .bringToMO,
                unit: Unit(
                    id: "1",
                    name: "Northwest Park - NA01/001",
                    bscUuid: nil, biUuid: nil, contractorUuid: nil, keyUuid: nil,
                    project: "Citraland Surabaya",
                    area: "Northwest Park",
                    block: "NA",
                    unitNumber: "01/001",
                    handoverDate: nil,
                    renovationPermit: false,
                    isApproved: true
                ),
                // ✅ FIX: Make this ID match the statusId above.
                status: Status(id: "4", name: "in_progress")
            ),
            complaintListViewModel: ComplaintListViewModel()
        )
    }
}
