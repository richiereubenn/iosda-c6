//
//  UnitRequestCard.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 02/09/25.
//

import SwiftUI

struct UnitRequestCard: View {
    let unit: Unit
    let userUnit: UserUnit?
    
    init(unit: Unit, userUnit: UserUnit? = nil) {
        self.unit = unit
        self.userUnit = userUnit
    }
    
    private var statusText: String {
        unit.isApproved == true ? "Approved" : "Pending"
    }
    
    private var statusColor: Color {
        unit.isApproved == true ? .green : .orange
    }
    
    private var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: unit.handoverDate ?? Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(unit.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let ownershipType = userUnit?.ownershipType {
                    Text("Requester: \(ownershipType)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Unknown Requester")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(statusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor)
                    .cornerRadius(6)
                
                Text(displayDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
