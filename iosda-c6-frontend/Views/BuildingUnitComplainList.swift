//
//  BuildingUnitComplainList.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import SwiftUI

struct BuildingUnitComplainList: View {
    @State private var searchText = ""
    @State private var sortOption: SortOption = .latest
    
    private let sampleUnits = [
        UnitComplainData(unitCode: "HC-0001", latestComplaintDate: "2023-10-26", totalComplaints: 8, completedComplaints: 8),
        UnitComplainData(unitCode: "HC-0002", latestComplaintDate: "2023-10-25", totalComplaints: 12, completedComplaints: 2),
        UnitComplainData(unitCode: "HC-0003", latestComplaintDate: "2023-10-24", totalComplaints: 6, completedComplaints: 3),
        UnitComplainData(unitCode: "HC-0004", latestComplaintDate: "2023-10-23", totalComplaints: 15, completedComplaints: 2)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Building Complain List")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                Menu {
                    Button(action: { sortOption = .latest }) {
                        Label("Tanggal Terbaru", systemImage: sortOption == .latest ? "checkmark" : "")
                    }
                    Button(action: { sortOption = .oldest }) {
                        Label("Tanggal Terlama", systemImage: sortOption == .oldest ? "checkmark" : "")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.primaryBlue)
                        .font(.title)
                }
            }
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
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredAndSortedUnits, id: \.unitCode) { unit in
                        UnitComplainCard(
                            unitCode: unit.unitCode,
                            latestComplaintDate: unit.latestComplaintDate,
                            totalComplaints: unit.totalComplaints,
                            completedComplaints: unit.completedComplaints
                        )
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top)
    }
    
    private var filteredAndSortedUnits: [UnitComplainData] {
        let filtered = searchText.isEmpty ?
            sampleUnits :
            sampleUnits.filter { $0.unitCode.localizedCaseInsensitiveContains(searchText) }
        
        return filtered.sorted {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let date1 = dateFormatter.date(from: $0.latestComplaintDate),
                  let date2 = dateFormatter.date(from: $1.latestComplaintDate) else {
                return false
            }
            return sortOption == .latest ? date1 > date2 : date1 < date2
        }
    }
}

struct UnitComplainData {
    let unitCode: String
    let latestComplaintDate: String
    let totalComplaints: Int
    let completedComplaints: Int
}

enum SortOption {
    case latest
    case oldest
}

#Preview {
    BuildingUnitComplainList()
}
