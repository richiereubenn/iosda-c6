//
//  UnitComplainCard.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 31/08/25.
//

import SwiftUI

struct UnitComplainCard: View {
    let unitCode: String
    let latestComplaintDate: String
    let totalComplaints: Int
    let completedComplaints: Int
    
    private var statusColor: Color {
        guard totalComplaints > 0 else { return .gray }
        let ratio = Double(completedComplaints) / Double(totalComplaints)
        
        if ratio == 1.0 {
            return .green
        } else if ratio >= 0.5 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(unitCode)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Latest Complaint Date")
                        .foregroundColor(.secondary)
                    
                    Text(latestComplaintDate)
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 8) {
                    Text("Total :")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("\(totalComplaints)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                Text("Done: \(completedComplaints)")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(statusColor)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 3, y: 3) 
    }
}

#Preview {
    VStack(spacing: 16) {
        UnitComplainCard(
            unitCode: "AXX/SDF",
            latestComplaintDate: "2025-08-30",
            totalComplaints: 10,
            completedComplaints: 3
        )
        
        UnitComplainCard(
            unitCode: "B-05",
            latestComplaintDate: "2025-08-25",
            totalComplaints: 10,
            completedComplaints: 6
        )
        
        UnitComplainCard(
            unitCode: "C-10",
            latestComplaintDate: "2025-08-20",
            totalComplaints: 8,
            completedComplaints: 8
        )
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
