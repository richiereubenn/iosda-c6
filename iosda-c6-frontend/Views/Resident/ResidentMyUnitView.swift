import SwiftUI

struct ResidentMyUnitView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ResidentUnitListViewModel
    
    let userId: String
    
    @State private var searchText: String = ""
    @State private var selectedSegment: Int = 0 // 0 = Claimed, 1 = Waiting
    @State private var isPresentingAddUnit = false
    
    @State private var selectedAreaName: String = ""
    @State private var selectedUnitCodeName: String = ""
    @State private var selectedUnitCodeId: String = ""


    var filteredUnits: [Unit2] {
        let units = selectedSegment == 0 ? viewModel.claimedUnits : viewModel.waitingUnits
        if searchText.isEmpty {
            return units
        } else {
            return units.filter { ($0.name ?? "").localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Segmented control
            Picker("Unit Status", selection: $selectedSegment) {
                Text("Claimed").tag(0)
                Text("Waiting").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if viewModel.isLoading {
                ProgressView("Loading units...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let displayUnits = filteredUnits
                
                if displayUnits.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: selectedSegment == 0 ? "checkmark.circle" : "clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(selectedSegment == 0 ? "No claimed units" : "No waiting units")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text(selectedSegment == 0 ? "Approved units will appear here" : "Units you submit will appear here")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(displayUnits) { unit in
                                Button(action: {
                                    if selectedSegment == 0 {
                                        viewModel.selectedUnit = unit  // ← Set selected unit here
                                        dismiss()
                                    }
                                }) {
                                    ResidentUnitCard(
                                        unit: unit,
                                        isClaimed: selectedSegment == 0,
                                        viewModel: viewModel
                                    )
                                    .foregroundColor(selectedSegment == 0 ? .primaryBlue : .gray)
                                }
                                .disabled(selectedSegment != 0)

                            }

                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            
            Spacer()
        }
        .navigationTitle("My Unit")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isPresentingAddUnit = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.primaryBlue)
                }
            }
        }
        .searchable(text: $searchText)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            if viewModel.claimedUnits.isEmpty && viewModel.waitingUnits.isEmpty {
                Task {
                    await viewModel.loadUnits()
                }
            }
        }

        .sheet(isPresented: $isPresentingAddUnit, onDismiss: {
            Task {
                await viewModel.loadUnits()
            }
        }) {
            ResidentAddUnitView(
                viewModel: AddUnitViewModel(),
                userId: userId,
                selectedAreaName: $selectedAreaName,
                selectedUnitCodeName: $selectedUnitCodeName,
                selectedUnitCodeId: $selectedUnitCodeId
            )
        }




    }
}

#Preview {
    NavigationStack {
        ResidentMyUnitView(viewModel: ResidentUnitListViewModel(),
        userId: "2b4fa7fe-0858-4365-859f-56d77ba53764")
    }
}
