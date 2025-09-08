import SwiftUI
struct ResidentHomeView: View {
    
    @ObservedObject var viewModel: ComplaintListViewModel
    @ObservedObject var unitViewModel: UnitViewModel
    @State private var showingCreateView = false
    
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
                if let claimedUnit = unitViewModel.selectedUnit {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(claimedUnit.name)
                                .font(.body)
                                .fontWeight(.medium)
                            if let project = claimedUnit.project {
                                Text(project)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()

                        NavigationLink(destination: ResidentMyUnitView(viewModel: unitViewModel)) {
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

                        NavigationLink(destination: ResidentMyUnitView(viewModel: unitViewModel)) {
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
                    
                    NavigationLink(destination: ResidentComplaintListView(viewModel: viewModel)) {
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
                            NavigationLink(destination: ResidentComplaintDetailView(complaint: complaint)) {
                                ResidentComplaintCardView(complaint: complaint)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }

            }
            
            Spacer()
        }
        .onAppear {
            // Load units only once, don't override selectedUnit
            if unitViewModel.units.isEmpty {
                unitViewModel.loadUnits()
            }
            
            // Only set default selectedUnit on first load when no unit is selected
            if unitViewModel.selectedUnit == nil && !unitViewModel.claimedUnits.isEmpty {
                unitViewModel.selectedUnit = unitViewModel.claimedUnits.first
            }
            
            Task {
                await viewModel.loadComplaints()
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingCreateView) {
            ResidentAddComplaintView(
                unitViewModel: unitViewModel, // Use same instance, not new one
                complaintViewModel: viewModel
            )
        }
    }
}


#Preview {
    NavigationStack {
        ResidentHomeView(
            viewModel: ComplaintListViewModel(),
            unitViewModel: UnitViewModel()
        )
        .navigationBarHidden(true)
    }
}
