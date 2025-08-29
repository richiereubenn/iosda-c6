//
//  BuildingComplainListView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import SwiftUI


struct BuildingComplainListView: View {
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Building Complain List")
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)

            SearchBar(searchText: $searchText)

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
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
    }
}


#Preview {
    BuildingComplainListView()
}
