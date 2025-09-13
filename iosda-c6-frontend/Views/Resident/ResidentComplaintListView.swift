import SwiftUI

struct ResidentComplaintListView: View {
    @StateObject var viewModel: ResidentComplaintListViewModel
    let userId: String

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
                            NavigationLink(destination: ResidentComplainDetailView(complaintId: complaint.id)) {
                                ResidentComplaintCard(complaint: complaint)
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
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.loadComplaints(byUserId: userId)
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
