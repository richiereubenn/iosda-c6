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
            
            HStack {
                Text("Latest Complaints from Units")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    print("View All tapped")
                }) {
                    Text("View All")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primaryBlue)
                }
            }
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.getFilteredAndSortedUnits(), id: \.unitCode) { unit in
                        NavigationLink(destination: BIComplaintDetailView()) {
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
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        BIHomepage()
    }
}
