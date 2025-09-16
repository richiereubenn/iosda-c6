import SwiftUI

struct ResidentComplaintListView: View {
    @StateObject var viewModel: ResidentComplaintListViewModel
    @StateObject private var detailViewModel = ResidentComplaintDetailViewModel()
    @StateObject private var unitViewModel = ResidentUnitListViewModel() // ✅ Add this
    
    let userId: String
    @State private var isPresentingAddComplaint = false
    @State private var currentUserId: String? = nil // ✅ Add this

    
    var body: some View {
        VStack {
            // Complaint Filter Picker
            Picker("Complaint Status", selection: $viewModel.selectedFilter) {
                ForEach(ResidentComplaintListViewModel.ComplaintFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Loading State
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .padding(.top, 40)
                Spacer()
            }
            
            // Empty State
            else if viewModel.filteredComplaints.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("No complaints found")
                        .font(.body.weight(.medium))
                        .foregroundColor(.secondary)
                        .minimumScaleFactor(0.8)
                        .lineLimit(2)
                }
                .padding(.top, 40)
                Spacer()
            }
            
            // Complaint List
            else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.filteredComplaints) { complaint in
                            NavigationLink(
                                destination: ResidentComplainDetailView(
                                    complaintId: complaint.id,
                                    viewModel: detailViewModel
                                )
                            ) {
                                ResidentComplaintCard(
                                    complaint: complaint,
                                    unitName: viewModel.unitNames[complaint.unitId ?? ""]
                                )
                                // ✅ fetch key logs for this unit when card appears
//                                .task {
//                                    if let unitId = complaint.unitId {
//                                        await detailViewModel.loadKeyLogs(unitId: unitId)
//                                    }
//                                }
                            }
                            
                            .buttonStyle(PlainButtonStyle())
                            
                            
                        }
                        
                    }
                    .padding(.horizontal)
                }
            }
        }
        
        .searchable(text: $viewModel.searchText, prompt: "Search complaints...")
        .navigationTitle("Complaint List")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isPresentingAddComplaint = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.primaryBlue)
                }
            }
        }

        .sheet(isPresented: $isPresentingAddComplaint) {
            NavigationStack {
                ResidentAddComplaintView(
                    unitViewModel: unitViewModel,
                    complaintViewModel: ResidentAddComplaintViewModel(),
                    complaintListViewModel: viewModel,
                    onComplaintSubmitted: {
                        print("🔥 DEBUG: onComplaintSubmitted called from COMPLAINT LIST VIEW")
                        Task {
                            if let userId = NetworkManager.shared.getUserIdFromToken() {
                                print("🔥 DEBUG: Refreshing complaints with userId: \(userId)")
                                await viewModel.loadComplaints(byUserId: userId)
                                print("🔥 DEBUG: Refresh completed from complaint list")
                            } else {
                                print("🔥 DEBUG: No userId found for refresh")
                            }
                        }
                    },
                    classificationId: "75b125fd-a656-4fd8-a500-2f051b068171",
                    latitude: 0.0,
                    longitude: 0.0
                )
                .onAppear {
                    print("🔥 DEBUG: AddComplaintView appeared from COMPLAINT LIST")
                    print("🔥 DEBUG: unitViewModel units count: \(unitViewModel.claimedUnits.count)")
                    print("🔥 DEBUG: unitViewModel selectedUnit: \(unitViewModel.selectedUnit?.name ?? "none")")
                    print("🔥 DEBUG: complaintListViewModel complaints count: \(viewModel.complaints.count)")
                    print("🔥 DEBUG: classificationId: 75b125fd-a656-4fd8-a500-2f051b068171")
                    
                    // Check if view models are properly initialized
                    print("🔥 DEBUG: unitViewModel object: \(ObjectIdentifier(unitViewModel))")
                    print("🔥 DEBUG: viewModel object: \(ObjectIdentifier(viewModel))")
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
                .task {
                    if let userId = NetworkManager.shared.getUserIdFromToken() {
                        currentUserId = userId // ✅ Store it
                        await viewModel.loadComplaints(byUserId: userId)
                        await unitViewModel.loadUnits() // ✅ Load units too
                    } else {
                        viewModel.errorMessage = "Failed to get user ID from token"
                    }
                }
            
        

        .background(Color(.systemGroupedBackground))
        .task {
                if let userId = NetworkManager.shared.getUserIdFromToken() {
                    await viewModel.loadComplaints(byUserId: userId)
                    await unitViewModel.loadUnits() // Load units
                    
                    // Set default selection like in working view
                    if unitViewModel.selectedUnit == nil && !unitViewModel.claimedUnits.isEmpty {
                        unitViewModel.selectedUnit = unitViewModel.claimedUnits.first
                    }
                }
            }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    NavigationStack {
        ResidentComplaintListView(
            viewModel: ResidentComplaintListViewModel(),
            userId: "2b4fa7fe-0858-4365-859f-56d77ba53764" // Replace with your test user ID
        )
    }
}
