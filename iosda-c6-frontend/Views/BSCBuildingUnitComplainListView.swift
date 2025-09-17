//
//  BSCBuildingUnitComplainListView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

struct BSCBuildingUnitComplainListView: View {
    @StateObject private var viewModel = BSCBuildingUnitComplainListViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        Text("Loading...")
                            .font(.headline)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Konten utama
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            SummaryComplaintCard(
                                title: "Total Units",
                                count: viewModel.totalActiveUnits,
                                category: " Units",
                                backgroundColor: Color(Color.primaryBlue),
                                icon: "building.2.fill"
                            )
                            
                            SummaryComplaintCard(
                                title: "Total Complaints",
                                count: viewModel.totalActiveComplaints,
                                category: " Complaints",
                                backgroundColor: Color(red: 10/255, green: 100/255, blue: 80/255),
                                icon: "exclamationmark.bubble.fill"
                            )
                        }
                        
                        unitListScrollView()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .background(Color(.systemGroupedBackground))
                    .searchable(text: $viewModel.searchText)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title2)
                                .foregroundColor(.primaryBlue)
                        }
                    }
                }
            }
            .navigationTitle("Building Complain List")
            .task {
                await viewModel.fetchUnits()
                await viewModel.fetchSummary()
            }
        }
    }
    
    @ViewBuilder
    private func unitListScrollView() -> some View {
        let units = viewModel.getFilteredAndSortedUnits()
        
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(units) { unit in
                    let summary = viewModel.getComplaintCounts(for: unit.id)
                    
                    NavigationLink(destination: BSCComplaintListView(unitId: unit.id, unitName: unit.name!)) {
                        UnitComplainCard(
                            unitCode: unit.name ?? "Unknown",
                            latestComplaintDate: formatDate(unit.createdAt!, format: "dd MMM yyyy"),
                            totalComplaints: summary.total,
                            completedComplaints: summary.completed
                        )
                    }
                    .contentShape(Rectangle())
                }
                
            }
        }
        
    }
    
    
    
    //    private var toolbarContent: some ToolbarContent {
    //        ToolbarItem(placement: .navigationBarTrailing) {
    //            let menuContent = Menu {
    //                let latestButton = Button(action: { viewModel.sortOption = .latest }) {
    //                    let latestLabel = Label("Tanggal Terbaru", systemImage: viewModel.sortOption == .latest ? "checkmark" : "")
    //                    latestLabel
    //                }
    //
    //                let oldestButton = Button(action: { viewModel.sortOption = .oldest }) {
    //                    let oldestLabel = Label("Tanggal Terlama", systemImage: viewModel.sortOption == .oldest ? "checkmark" : "")
    //                    oldestLabel
    //                }
    //
    //                latestButton
    //                oldestButton
    //            } label: {
    //                let menuIcon = Image(systemName: "line.3.horizontal.decrease.circle")
    //                    .font(.title2)
    //                    .foregroundColor(Color.primaryBlue)
    //                menuIcon
    //            }
    //            menuContent
    //        }
    //    }
}

#Preview {
    NavigationStack {
        BSCBuildingUnitComplainListView()
    }
}
