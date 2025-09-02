//
//  BuildingListViewModel.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 31/08/25.
//

import Foundation

class BuildingListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .latest
    
    func getFilteredAndSortedUnits() -> [UnitComplainData] {
        let filtered = filterUnits(search: searchText)
        return sortUnits(units: filtered, option: sortOption)
    }
    private func filterUnits(search: String) -> [UnitComplainData] {
        guard !search.isEmpty else { return units }
        return units.filter { $0.unitCode.localizedCaseInsensitiveContains(search) }
    }
    
    private func sortUnits(units: [UnitComplainData], option: SortOption) -> [UnitComplainData] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return units.sorted {
            guard let date1 = dateFormatter.date(from: $0.latestComplaintDate),
                  let date2 = dateFormatter.date(from: $1.latestComplaintDate) else {
                return false
            }
            return option == .latest ? date1 > date2 : date1 < date2
        }
    }
    
    
    @Published private(set) var units: [UnitComplainData] = [
        UnitComplainData(unitCode: "HC-0001", latestComplaintDate: "2023-10-26", totalComplaints: 8, completedComplaints: 8),
        UnitComplainData(unitCode: "HC-0002", latestComplaintDate: "2023-10-25", totalComplaints: 12, completedComplaints: 2),
        UnitComplainData(unitCode: "HC-0003", latestComplaintDate: "2023-10-24", totalComplaints: 6, completedComplaints: 3),
        UnitComplainData(unitCode: "HC-0004", latestComplaintDate: "2023-10-23", totalComplaints: 15, completedComplaints: 2)
    ]
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
