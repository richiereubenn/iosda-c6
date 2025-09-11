//
//  BIHomepage.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

struct BIHomepage: View {
    @StateObject private var viewModel = BuildingListViewModel()
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Hello, Richie")
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
            
            HStack(spacing: 16) {
                SummaryComplaintCard(
                    title: "New Complaint",
                    unitCount: 13,
                    complaintCount: 20,
                    backgroundColor: .blue
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("New Complaint")
                .accessibilityValue("13 units, 20 complaints")
                
                SummaryComplaintCard(
                    title: "On Progress",
                    unitCount: 2,
                    complaintCount: 5,
                    backgroundColor: .green
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("On Progress")
                .accessibilityValue("2 units, 5 complaints")
            }
            
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
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.getFilteredAndSortedUnits(), id: \.unitCode) { unit in
                        NavigationLink(destination: BIComplaintListView(viewModel: ComplaintListViewModel2())) {
                            UnitComplainCard(
                                unitCode: unit.unitCode,
                                latestComplaintDate: unit.latestComplaintDate,
                                totalComplaints: unit.totalComplaints,
                                completedComplaints: unit.completedComplaints
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Unit \(unit.unitCode)")
                        .accessibilityValue("\(unit.totalComplaints) complaints, \(unit.completedComplaints) completed. Latest complaint on \(unit.latestComplaintDate ?? "unknown date").")
                        .accessibilityHint("Double tap to view complaints for this unit")
                    }
                }
            }
            
            Spacer()
        }
        
        .padding(.horizontal)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        BIHomepage()
    }
}
