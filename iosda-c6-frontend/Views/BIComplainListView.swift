//
//  BSCComplainList.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 03/09/25.
//

import SwiftUI

struct BIComplaintListView: View {
    @StateObject var viewModel = ComplaintListViewModel2()
    
    var body: some View {
        VStack {
            Picker("Complaint Status", selection: $viewModel.selectedFilter) {
                ForEach(ComplaintListViewModel2.ComplaintFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if viewModel.isLoading {
                ProgressView("Loading...")
                Spacer()
            } else if viewModel.filteredComplaints.isEmpty {
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
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.filteredComplaints) { complaint in
                            NavigationLink(destination: BIComplaintDetailView(complaintId: complaint.id)) {
                                ComplaintCard(complaint: complaint)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search complaints...")
        .navigationTitle("Kode Rumah")
        .task {
            await viewModel.loadComplaints(byUnitId: "103e4567-e89b-12d3-a456-426614174000")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .background(Color(.systemGroupedBackground))
    }
}



#Preview {
    Group {
        NavigationStack {
            BIComplaintListView(viewModel: ComplaintListViewModel2())
        }
        .environment(\.sizeCategory, .medium)
        
    }
}

