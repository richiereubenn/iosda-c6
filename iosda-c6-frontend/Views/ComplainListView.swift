//
//  ComplainListView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 31/08/25.
//

import SwiftUI

struct ComplaintListView: View {
    @ObservedObject var viewModel: ComplaintListViewModel
    @State private var searchText: String = ""
    @State private var showingCreateView = false

    var body: some View {
        VStack(spacing: 8) {
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
            
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding(.top, 40)
                    Spacer()
                } else if viewModel.filteredComplaints.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No complaints found")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredComplaints) { complaint in
                                NavigationLink(
                                    destination: BIComplaintDetailView() 
                                ) {
                                    ResidentComplaintCardView(complaint: complaint)
                                }
                                .buttonStyle(PlainButtonStyle()) 
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }

                }
            }
        }
        .background(Color.white)
        .navigationTitle("Kode Rumah")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search complaints...")
        .onAppear {
            Task {
                await viewModel.loadComplaints()
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
        ComplaintListView(viewModel: ComplaintListViewModel())
    }
}

