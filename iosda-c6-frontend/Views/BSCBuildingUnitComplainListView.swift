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
                        // Loading screen bawaan Apple
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
                                    category: " Complaint",
                                    backgroundColor: Color.blue,
                                    icon: "building.2.fill"
                                )
                                
                                SummaryComplaintCard(
                                    title: "Total Complaints",
                                    count: viewModel.totalActiveComplaints,
                                    category: " Unit",
                                    backgroundColor: Color.red,
                                    icon: "building.2.fill"
                                )
                            }
                            
                            unitListScrollView()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .background(Color(.systemGroupedBackground))
                        .searchable(text: $viewModel.searchText)
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
                    
                    NavigationLink(destination: BSCComplaintListView(unitId: unit.id)) {
                        UnitComplainCard(
                            unitCode: unit.name ?? "Unknown",
                            latestComplaintDate: formatDate(unit.createdAt!, format: "dd MMM yyyy | HH:mm:ss"),
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
