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
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                SummaryComplaintCard(
                    title: "New Complaint",
                    unitCount: 13,
                    complaintCount: 20,
                    backgroundColor: Color.blue.opacity(0.3)
                )
                SummaryComplaintCard(
                    title: "On Progress",
                    unitCount: 2,
                    complaintCount: 5,
                    backgroundColor: Color.green.opacity(0.3)
                )
            }
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.getFilteredAndSortedUnits(), id: \.unitCode) { unit in
                        NavigationLink(destination: ComplaintListView(viewModel: ComplaintListViewModel())) {
                            UnitComplainCard(
                                unitCode: unit.unitCode,
                                latestComplaintDate: unit.latestComplaintDate,
                                totalComplaints: unit.totalComplaints,
                                completedComplaints: unit.completedComplaints
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { viewModel.sortOption = .latest }) {
                        Label("Tanggal Terbaru", systemImage: viewModel.sortOption == .latest ? "checkmark" : "")
                    }
                    Button(action: { viewModel.sortOption = .oldest }) {
                        Label("Tanggal Terlama", systemImage: viewModel.sortOption == .oldest ? "checkmark" : "")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title2)
                        .foregroundColor(Color.primaryBlue)
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .navigationTitle("Building Complain List")
        
    }
}

#Preview {
    NavigationStack {
        BSCBuildingUnitComplainListView()
    }
}
