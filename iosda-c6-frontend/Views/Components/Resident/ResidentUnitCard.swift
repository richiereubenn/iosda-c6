//
//  UnitCard.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 31/08/25.
//
import SwiftUI

struct ResidentUnitCard: View {
    let unit: Unit2
    let isClaimed: Bool
       @ObservedObject var viewModel: ResidentUnitListViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
//                if let ownershipType = userUnit.ownershipType {
//                    Text(ownershipType)
//                        .font(.caption)
//                        .foregroundColor(.green)
//                }
                Text(isClaimed ? "Claimed" : "Waiting")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isClaimed ? .green : .orange)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background((isClaimed ? Color.green.opacity(0.1) : Color.orange.opacity(0.1)))
                    .cornerRadius(8)

                Text(unit.name ?? "Unknown Unit")
                                    .font(.headline)
                                    //.foregroundColor(.primaryBlue)
                // Header with status indicator
                if let projectName = viewModel.getProjectName(for: unit) {
                                    Text(projectName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
            }
            Spacer()
//            
//            Image(systemName: "chevron.right")
//                .foregroundColor(.gray)

                
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}
