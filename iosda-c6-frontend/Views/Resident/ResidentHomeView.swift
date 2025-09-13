import SwiftUI

struct ResidentHomeView: View {
    
    @ObservedObject var viewModel: ResidentComplaintListViewModel
//    @ObservedObject var unitViewModel: UnitViewModel
    @ObservedObject var unitViewModel: ResidentUnitListViewModel

    @State private var showingCreateView = false
    
    // 1. Add a userId property to accept the user's ID
    let userId: String
    
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
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 15) {
                if let claimedUnit = unitViewModel.claimedUnits.first {
                    HStack {
                        VStack(alignment: .leading) {
//                            Text(claimedUnit.name ?? "Unknown Unit")
//                                .font(.body)
//                                .fontWeight(.medium)
                            let unitToShow = unitViewModel.selectedUnit ?? unitViewModel.claimedUnits.first

                            if let unit = unitToShow {
                                Text(unit.name ?? "Unknown Unit")
                                    .font(.body)
                                    .fontWeight(.medium)
                                if let projectName = unitViewModel.getProjectName(for: unit) {
                                            Text(projectName)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                            } else {
                                Text("No units have been claimed yet")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }

                        }
                        Spacer()

                        NavigationLink(destination: ResidentMyUnitView(viewModel: unitViewModel, userId: userId)) {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.blue)
                        }

                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(10)
                } else {
                    HStack {
                        Text("No units have been claimed yet")
                            .foregroundColor(.gray)
                            .font(.body)

                        Spacer()

                        NavigationLink(destination: ResidentMyUnitView(viewModel: ResidentUnitListViewModel(), userId: userId)) {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(10)
                }

                // New Complaint Button
                CustomButtonComponent(text: "New Complaint", action: {
                                            showingCreateView = true
                                      })
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
                    
                    // 2. Use the new userId property for the navigation link
                    NavigationLink(destination: ResidentComplaintListView(
                        viewModel: ResidentComplaintListViewModel(),
                        userId: userId
                    )) {
                        Text("View All")
                            .foregroundColor(.blue)
                            .font(.body)
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
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            // Load units only once, don't override selectedUnit
            if unitViewModel.claimedUnits.isEmpty && unitViewModel.waitingUnits.isEmpty {
                Task {
                    await unitViewModel.loadUnits()
                }
            }

            
            // Only set default selectedUnit on first load when no unit is selected
            if unitViewModel.selectedUnit == nil && !unitViewModel.claimedUnits.isEmpty {
                unitViewModel.selectedUnit = unitViewModel.claimedUnits.first
            }
            
            Task {
                // 3. Call the correct function to load complaints by user ID
                await viewModel.loadComplaints(byUserId: userId)
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingCreateView) {
            ResidentAddComplaintView(
                unitViewModel: unitViewModel,
                complaintViewModel: ResidentAddComplaintViewModel(),
                classificationId: "75b125fd-a656-4fd8-a500-2f051b068171",
                latitude: 0.0,
                longitude: 0.0
            )
        }


    }
}


#Preview {
    NavigationStack {
        // 4. Update the preview to provide a test user ID
        ResidentHomeView(
            viewModel: ResidentComplaintListViewModel(),
            unitViewModel: ResidentUnitListViewModel(),
            userId: "2b4fa7fe-0858-4365-859f-56d77ba53764"
        )
        .navigationBarHidden(true)
    }
}
