
import SwiftUI

struct ResidentMyUnitView: View {
    @StateObject private var viewModel = UnitViewModel()
    @State private var searchText: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            // Search Bar
//            SearchBar(searchText: $searchText)
//            SearchBar(text: $searchText)
//                .padding(.horizontal, 5)
//                .padding(.top, 8)
            
            // Segmented Control
            Picker("Unit Status", selection: $viewModel.selectedSegment) {
                Text("Claimed").tag(0)
                Text("Waiting").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Content
            if viewModel.isLoading {
                ProgressView("Loading units...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let displayUnits = viewModel.searchUnits(with: searchText)
                
                if displayUnits.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: viewModel.selectedSegment == 0 ? "checkmark.circle" : "clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text(viewModel.selectedSegment == 0 ? "No claimed units" : "No waiting units")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text(viewModel.selectedSegment == 0 ? "Approved units will appear here" : "Units you submit will appear here")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(displayUnits) { unit in
                                if let userUnit = viewModel.getUserUnit(for: unit) {
                                    ResidentUnitCard(unit: unit, userUnit: userUnit)
                                }
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
                    viewModel.showingAddUnit = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color(.blue))
                }
            }
        }
        .searchable(text: $searchText)
        .sheet(isPresented: $viewModel.showingAddUnit) {
            ResidentAddUnitView(viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            viewModel.loadUnits()
        }
    }
}



#Preview {
    NavigationStack {
        ResidentMyUnitView()
    }
}
