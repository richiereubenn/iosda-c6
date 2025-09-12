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
        NavigationStack{
            VStack(spacing: 16) {
                
                HStack(spacing: 16) {
                    SummaryComplaintCard(
                        title: "New Complaint",
                        unitCount: 13,
                        complaintCount: 20,
                        backgroundColor: Color.blue
                    )
                    
                    SummaryComplaintCard(
                        title: "On Progress",
                        unitCount: 2,
                        complaintCount: 5,
                        backgroundColor: Color.green
                    )
                }
                
                unitListScrollView()
                
            }
            .padding(.horizontal)
            .padding(.top)
            .background(Color(.systemGroupedBackground))
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Building Complain List")
            .task {
                await viewModel.fetchUnits()
            }
            
            .background(Color(.systemGroupedBackground))
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
