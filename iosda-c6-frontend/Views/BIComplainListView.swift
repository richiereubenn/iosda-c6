//
//  BSCComplainList.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 03/09/25.
//

import SwiftUI

struct BIComplaintListView: View {
    let unitId: String
    let unitCode: String
    @StateObject var viewModel = ComplaintListViewModel2()
    
    var body: some View {
        VStack {
            // Tampilkan info filter saat ini
            if !viewModel.isLoading {
                HStack {
                    Text("Filter: \(viewModel.selectedFilter.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if viewModel.filteredComplaints.isEmpty {
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    
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
                }
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.filteredComplaints) { complaint in
                            ComplaintRow(complaint: complaint)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search complaints...")
        .navigationTitle(unitCode)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(ComplaintListViewModel2.ComplaintFilter.allCases, id: \.self) { filter in
                        Button {
                            viewModel.selectedFilter = filter
                        } label: {
                            Label(filter.rawValue,
                                  systemImage: viewModel.selectedFilter == filter ? "checkmark" : "")
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title2)
                        .foregroundColor(.primaryBlue)
                }
            }
        }
        .task {
            await viewModel.loadComplaints(byUnitId: unitId)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - ComplaintRow Subview
struct ComplaintRow: View {
    let complaint: Complaint2
    
    var body: some View {
        NavigationLink(destination: BIComplaintDetailView(complaintId: complaint.id, complaintName: complaint.title)) {
            ComplaintCard(complaint: complaint)
        }
    }
}
