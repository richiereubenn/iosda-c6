import SwiftUI

struct ResidentHomeView: View {
    
    @ObservedObject var viewModel: ResidentComplaintListViewModel
    @ObservedObject var unitViewModel: ResidentUnitListViewModel
    @StateObject private var detailViewModel = ResidentComplaintDetailViewModel()
    
    @State private var showingPhotoUpload = false


    
    @State private var showingCreateView = false
    @State private var showSuccessAlert = false
    @State private var userId: String? = nil
    
    var onComplaintSubmitted: (() -> Void)? = nil
    
    var waitingKeyComplaint: Complaint2? {
        viewModel.complaints.first {
            ComplaintStatus(raw: $0.statusName) == .waitingKeyHandover
        }
    }

    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Ciputra Help")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundColor(.primaryBlue)
                            .font(.title2)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.primaryBlue)
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 15) {
                // Unit Selection Card
                HStack {
                    VStack(alignment: .leading) {
                        if let selectedUnit = unitViewModel.selectedUnit {
                            Text(selectedUnit.name ?? "Unknown Unit")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primaryBlue)
                            if let projectName = unitViewModel.getProjectName(for: selectedUnit) {
                                Text(projectName)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        } else if let firstClaimedUnit = unitViewModel.claimedUnits.first {
                            Text(firstClaimedUnit.name ?? "Unknown Unit")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primaryBlue)
                            if let projectName = unitViewModel.getProjectName(for: firstClaimedUnit) {
                                Text(projectName)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Text("No units have been claimed yet")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    if let id = userId {
                        NavigationLink(destination: ResidentMyUnitView(viewModel: unitViewModel, userId: id)) {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.primaryBlue)
                        }
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(10)
                
                // New Complaint Button
                CustomButtonComponent(
                    text: "New Complaint",
                    backgroundColor: .primaryBlue,
                    action: {
                        // Ensure a unit is selected before opening complaint creation
                        if unitViewModel.selectedUnit == nil && !unitViewModel.claimedUnits.isEmpty {
                            unitViewModel.selectedUnit = unitViewModel.claimedUnits.first
                        }
                    showingCreateView = true
                })
                .disabled(unitViewModel.claimedUnits.isEmpty) // Disable if no units available
                
                // 🔑 Submit Key Button
                if let complaint = waitingKeyComplaint,
                   let unit = unitViewModel.selectedUnit {
                    CustomButtonComponent(
                        text: "Submit Key for \(unit.name ?? "Unit")",
                        backgroundColor: .primaryBlue
                    ) {
                        showingPhotoUpload = true
                    }

                }


                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            
            // Recent Complaint Section
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("RECENT COMPLAINT")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if let id = userId {
                        NavigationLink(destination: ResidentComplaintListView(
                            viewModel: ResidentComplaintListViewModel(),
                            userId: id
                        )) {
                            Text("View All")
                                .foregroundColor(.primaryBlue)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                
                // Complaint List
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(viewModel.complaints.prefix(5)) { complaint in
                            NavigationLink(destination: ResidentComplainDetailView(complaintId: complaint.id)) {
                                ResidentComplaintCard(complaint: complaint)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingPhotoUpload) {
            PhotoUploadSheet(
                title: .constant("Key Handover Evidence"),
                description: .constant("Please provide a description of the key handover."),
                uploadAmount: .constant(1),
                showTitleField: false,
                showDescriptionField: true,
                onStartWork: { _, _, description in
                    Task {
                        if let complaint = waitingKeyComplaint,
                           let userId = NetworkManager.shared.getUserIdFromToken() {
                            await detailViewModel.submitKeyHandoverEvidence(
                                complaintId: complaint.id,
                                userId: userId,
                                description: (description?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
                                    ? "Key submitted via Home screen"
                                    : description!
                            )

                            // 🔄 Refresh the complaints list and the specific complaint detail
                            await viewModel.loadComplaints(byUserId: userId)
                            await detailViewModel.loadComplaint(byId: complaint.id)

                            if let updated = viewModel.complaints.first(where: { $0.id == complaint.id }) {
                                print("🔄 Updated complaint status: \(updated.statusName)")
                            }

                        }
                        showingPhotoUpload = false
                    }
                },
                onCancel: {
                    showingPhotoUpload = false
                }
            )
        }

        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            // Load units only once
            if unitViewModel.claimedUnits.isEmpty && unitViewModel.waitingUnits.isEmpty {
                Task {
                    await unitViewModel.loadUnits()
                }
            }
            
            // Set default selectedUnit on first load when no unit is selected
            if unitViewModel.selectedUnit == nil && !unitViewModel.claimedUnits.isEmpty {
                unitViewModel.selectedUnit = unitViewModel.claimedUnits.first
            }
            
            Task {
                // Load complaints by user ID for recent complaints section
                if let id = NetworkManager.shared.getUserIdFromToken() {
                    userId = id
                    await viewModel.loadComplaints(byUserId: id)
                } else {
                    viewModel.errorMessage = "Unable to get user ID from token"
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingCreateView) {
            ResidentAddComplaintView(
                unitViewModel: unitViewModel,
                complaintViewModel: ResidentAddComplaintViewModel(),
                complaintListViewModel: viewModel, // ✅ use the same one
                onComplaintSubmitted: {
                    Task {
                        if let id = userId {
                            await viewModel.loadComplaints(byUserId: id) // refresh Home
                        }
                    }
                },
                classificationId: "75b125fd-a656-4fd8-a500-2f051b068171",
                latitude: 0.0,
                longitude: 0.0
            )
        }

    }
}

#Preview {
    NavigationStack {
        ResidentHomeView(
            viewModel: ResidentComplaintListViewModel(),
            unitViewModel: ResidentUnitListViewModel()
        )
        .navigationBarHidden(true)
    }
}
