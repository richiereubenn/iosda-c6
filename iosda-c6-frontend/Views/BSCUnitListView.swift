//
//  BSCUnitListView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 02/09/25.
//

import SwiftUI

struct BSCUnitListView: View {
    @StateObject private var viewModel = UnitViewModel()
    @State private var searchText = ""
    
    private var filteredUnits: [Unit] {
        viewModel.searchUnits(with: searchText)
    }
    
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
                    count: viewModel.claimedUnits.count,
                    backgroundColor: .green,
                    icon: "checkmark.circle.fill"
                )
                
            }
            
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading units...")
                Spacer()
            } else if filteredUnits.isEmpty && !searchText.isEmpty {
                Spacer()
                Text("No units found for '\(searchText)'")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredUnits, id: \.id) { unit in
                            NavigationLink {
                                BSCUnitDetailView(
                                    unit: unit,
                                    userUnit: viewModel.getUserUnit(for: unit),
                                    viewModel: viewModel
                                )
                            } label: {
                                UnitRequestCard(
                                    unit: unit,
                                    userUnit: viewModel.getUserUnit(for: unit)
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
        .searchable(text: $searchText, prompt: "Cari unit, area, atau project...")
        .navigationTitle("Unit Request List")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { viewModel.selectedSegment = 0 }) {
                        Label("Unit Terdaftar", systemImage: viewModel.selectedSegment == 0 ? "checkmark" : "")
                    }
                    Button(action: { viewModel.selectedSegment = 1 }) {
                        Label("Unit Pending", systemImage: viewModel.selectedSegment == 1 ? "checkmark" : "")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
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
