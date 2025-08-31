import SwiftUI

struct ResidentComplaintListView: View {
    @StateObject private var viewModel = ComplaintListViewModel()
    @State private var showingCreateView = false
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                
                // Search Bar
//                SearchBar(searchText: $searchText)
//                    .padding(.horizontal, 5)
//                    .padding(.top, 8)
                
                // Picker
                Picker("Complaint Status", selection: $viewModel.selectedFilter) {
                    ForEach(ComplaintListViewModel.ComplaintFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: viewModel.selectedFilter) { _ in
                    viewModel.filterComplaints()
                }
                
                // Complaint List
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Spacer()
                } else if viewModel.filteredComplaints.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No complaints found")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredComplaints) { complaint in
                                ResidentComplaintCardView(complaint: complaint)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .background(Color.white)
            .navigationTitle("Complaint List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateView = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .searchable(text: $searchText)
            .onAppear {
                Task {
                    await viewModel.loadComplaints()
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $showingCreateView) {
                ResidentAddComplaintView(
                    unitViewModel: UnitViewModel(), // or pass the real one if you have
                    complaintViewModel: viewModel  // <-- Pass the same ViewModel instance here!
                )
            }

        }
    }
}

#Preview {
    ResidentComplaintListView()
}


