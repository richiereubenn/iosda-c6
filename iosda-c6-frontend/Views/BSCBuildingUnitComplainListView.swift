//
//  BSCBuildingUnitComplainListView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

struct BSCBuildingUnitComplainListView: View {
    @StateObject private var viewModel = BuildingListViewModel()
    
    var body: some View {
        NavigationStack{
            let filteredUnits = viewModel.getFilteredAndSortedUnits()
            
            VStack(spacing: 16) {
                let summaryCardsHStack = HStack(spacing: 16) {
                    let newComplaintCard = SummaryComplaintCard(
                        title: "New Complaint",
                        unitCount: 13,
                        complaintCount: 20,
                        backgroundColor: Color.blue
                    )
                    
                    let progressCard = SummaryComplaintCard(
                        title: "On Progress",
                        unitCount: 2,
                        complaintCount: 5,
                        backgroundColor: Color.green
                    )
                    
                    newComplaintCard
                    progressCard
                }
                summaryCardsHStack
                
                let scrollableContent = ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredUnits, id: \.unitCode) { unit in
                            let destinationView = BSCComplaintListView(
                                viewModel: ComplaintListViewModel2()
                            )
                            
                            let unitCard = UnitComplainCard(
                                unitCode: unit.unitCode,
                                latestComplaintDate: unit.latestComplaintDate,
                                totalComplaints: unit.totalComplaints,
                                completedComplaints: unit.completedComplaints
                            )
                            
                            let navigationLink = NavigationLink(destination: destinationView) {
                                unitCard
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            navigationLink
                        }
                    }
                }
                scrollableContent
            }
            .padding(.horizontal)
            .background(Color(.systemGroupedBackground))
            .padding(.top)
            .toolbar {
                toolbarContent
            }
            .searchable(text: $viewModel.searchText)
            .navigationTitle("Building Complain List")
            
        }
        .background(Color(.systemGroupedBackground))
    }
    
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            let menuContent = Menu {
                let latestButton = Button(action: { viewModel.sortOption = .latest }) {
                    let latestLabel = Label("Tanggal Terbaru", systemImage: viewModel.sortOption == .latest ? "checkmark" : "")
                    latestLabel
                }
                
                let oldestButton = Button(action: { viewModel.sortOption = .oldest }) {
                    let oldestLabel = Label("Tanggal Terlama", systemImage: viewModel.sortOption == .oldest ? "checkmark" : "")
                    oldestLabel
                }
                
                latestButton
                oldestButton
            } label: {
                let menuIcon = Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundColor(Color.primaryBlue)
                menuIcon
            }
            menuContent
        }
    }
}

#Preview {
    NavigationStack {
        BSCBuildingUnitComplainListView()
    }
}
