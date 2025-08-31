//
//  UnitCard.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 31/08/25.
//
import SwiftUI

struct ResidentUnitCard: View {
    let unit: Unit
    let userUnit: UserUnit
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                if let ownershipType = userUnit.ownershipType {
                    Text(ownershipType)
                        .font(.caption)
                        .foregroundColor(.green)
                }
                Text(unit.name)
                    .font(.headline)
                // Header with status indicator
                
                if let project = unit.project {
                    Text(project)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)

                
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    ResidentUnitCard(
        unit: Unit(
            id: 1234,
            name: "Citraland Utara - 8/24",
            bscUuid: "2",
            biUuid: "2",
            contractorUuid: "2",
            keyUuid: "2",
            project: "Citraland Utara",
            area: "NorthWestPark",
            block: "NA",
            unitNumber: "8/24",
            handoverDate: nil,
            renovationPermit: true,
            isApproved: true
        ),
        userUnit: UserUnit(
            id: 1,
            userId: 123,
            unitId: 1234,
            ownershipType: "Owner"
        )
    )
    .padding()
}
