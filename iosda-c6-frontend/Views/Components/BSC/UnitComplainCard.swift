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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var isCompact: Bool { horizontalSizeClass == .compact }
    
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
            VStack(alignment: .leading, spacing: isCompact ? 10 : 10) {
                Text(unitCode)
                    .font(isCompact ? .title2 : .title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: isCompact ? 1 : 2) {
                    Text("Latest Complaint Date")
                        .foregroundColor(.secondary)
                    
                    Text(latestComplaintDate)
                        .foregroundColor(.secondary)
                }
                .font(isCompact ? .caption : .subheadline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: isCompact ? 10 : 8) {
                HStack(spacing: isCompact ? 4 : 8) {
                    Text("Total :")
                        .font(isCompact ? .body : .title3)
                        .foregroundColor(.secondary)
                    
                    Text("\(totalComplaints)")
                        .font(isCompact ? .title3 : .title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                Text("Done: \(completedComplaints)")
                    .font(isCompact ? .callout : .title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, isCompact ? 8 : 12)
                    .padding(.vertical, isCompact ? 4 : 8)
                    .background(statusColor)
                    .cornerRadius(8)
            }
        }
        .padding(isCompact ? 10 : 16)
        .background(Color.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
            //.stroke(Color(.separator), lineWidth: 0.5)
                .stroke(Color.cardBackground, lineWidth: 0.5)
        )
        .cornerRadius(12)
        //.shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    Group {
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
        .preferredColorScheme(.light) // ✅ Preview Light
        
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
        .preferredColorScheme(.dark)
    }
}
