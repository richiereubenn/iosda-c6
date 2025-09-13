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
                Text("Hello, Richie") // nanti bisa ambil dari token kalau mau
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundColor(.black)
                            .font(.title2)
                            .accessibilityLabel("Notifications")
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.black)
                            .font(.title2)
                            .accessibilityLabel("Profile")
                    }
                }
            }
            
            // Summary Cards ambil dari ViewModel
            HStack(spacing: 16) {
                SummaryComplaintCard(
                    title: "Total Units Complaint",
                    count: viewModel.totalActiveUnits,
                    category: " Complaint",
                    backgroundColor: Color.blue,
                    icon: "building.2.fill"
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("New Complaint")
                .accessibilityValue("\(viewModel.totalActiveUnits) units")
                
                SummaryComplaintCard(
                    title: "Total Complaints",
                    count: viewModel.totalActiveComplaints,
                    category: " Complaint",
                    backgroundColor: Color.red,
                    icon: "exclamationmark.bubble.fill"
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("On Progress")
                .accessibilityValue("\(viewModel.totalActiveComplaints) complaints")
            }
            
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
                        
                        NavigationLink(destination: BIComplaintListView(unitId: unit.id)) {
                            UnitComplainCard(
                                unitCode: unit.name ?? "Unknown",
                                latestComplaintDate: formatDate(unit.createdAt ?? Date(), format: "dd MMM yyyy | HH:mm:ss"),
                                totalComplaints: summary.total,
                                completedComplaints: summary.completed
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Unit \(unit.name ?? "Unknown")")
                        .accessibilityValue("\(summary.total) complaints, \(summary.completed) completed. Latest complaint on \(formatDate(unit.createdAt ?? Date(), format: "dd MMM yyyy"))")
                        .accessibilityHint("Double tap to view complaints for this unit")
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
