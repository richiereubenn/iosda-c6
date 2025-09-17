import SwiftUI

struct BSCUnitListView: View {
    @StateObject private var viewModel = BSCUnitListViewModel()
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                UnitStatusSummaryCard(
                    title: "Unit Request",
                    count: viewModel.waitingUnits.count,
                    backgroundColor: .orange,
                    icon: "clock.fill"
                )
                
                UnitStatusSummaryCard(
                    title: "Claimed Unit",
                    count: viewModel.approvedUnits.count,
                    backgroundColor: .green,
                    icon: "checkmark.circle.fill"
                )
            }
            Picker("", selection: $viewModel.selectedSegment) {
                Text("All").tag(0)
                Text("Pending").tag(1)
                Text("Approved").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical, 8)
            .onChange(of: viewModel.selectedSegment) { _ in
                viewModel.filterUnits(searchText: searchText)
            }
            
            // Unit List
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading units...")
                Spacer()
            } else if viewModel.filteredUnits.isEmpty && !searchText.isEmpty {
                Spacer()
                Text("No units found for '\(searchText)'")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredUnits, id: \.id) { unit in
                            NavigationLink {
                                BSCUnitDetailView(
                                    unitId: unit.id,
                                    viewModel: viewModel
                                )
                            } label: {
                                UnitRequestCard(
                                    unit: unit,
                                    resident: viewModel.getUser(for: unit)
                                )
                                .contentShape(Rectangle())
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
        }
        .padding(.horizontal)
        .background(Color(.systemGroupedBackground))
        .padding(.top)
        .searchable(text: $searchText, prompt: "Cari unit atau nomor...")
        .onChange(of: searchText) { newValue in
            viewModel.filteredUnits
        }
        .navigationTitle("Unit Request List")
        .onAppear {
            viewModel.loadUnits()
        }
    }
}

#Preview {
    NavigationStack {
        BSCUnitListView()
    }
}
