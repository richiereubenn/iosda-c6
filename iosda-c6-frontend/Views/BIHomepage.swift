//
//  BIHomepage.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

struct BIHomepage: View {
    @StateObject private var viewModel = BIHomepageViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("CiputraHelp") 
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundColor(.primaryBlue)
                            .font(.title2)
                            .accessibilityLabel("Notifications")
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.primaryBlue)
                            .font(.title2)
                            .accessibilityLabel("Profile")
                    }
                }
            }
            
            // Summary Cards ambil dari ViewModel
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
            .padding(.bottom, 8)
            
            
            // Latest Complaints header
            HStack {
                Text("Latest Complaints from Units")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                Button(action: {
                    print("View All tapped")
                }) {
                    Text("View All")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primaryBlue)
                }
                .accessibilityHint("Shows all complaints")
            }
            
            // Unit List ambil dari ViewModel
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.getFilteredAndSortedUnits(), id: \.id) { unit in
                        let summary = viewModel.getComplaintCounts(for: unit.id)
                        let unitCode = unit.name ?? "Unknown"
                        let latestDate = unit.createdAt.map { formatDate($0, format: "dd MMM yyyy") } ?? "-"
                        
                        NavigationLink(destination: BIComplaintListView(unitId: unit.id, unitCode: unitCode)) {
                            UnitComplainCard(
                                unitCode: unitCode,
                                latestComplaintDate: latestDate,
                                totalComplaints: summary.total,
                                completedComplaints: summary.completed
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.fetchUnits()
            await viewModel.fetchSummary()
        }
    }
}

#Preview {
    NavigationStack {
        BIHomepage()
    }
}
