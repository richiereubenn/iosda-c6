//
//  SummaryComplaintCard.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import SwiftUI

struct SummaryComplaintCard: View {
    var title: String
    var unitCount: Int
    var complaintCount: Int
    var backgroundColor: Color

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 24)
                    
                    Text("\(String(format: "%02d", unitCount)) Unit")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                HStack {
                    Image(systemName: "list.bullet.clipboard.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 24)
                    
                    Text("\(String(format: "%03d", complaintCount)) Complaint")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        backgroundColor,
                        backgroundColor.opacity(0.7)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                LinearGradient(
                    colors: [
                        .white.opacity(0.15),
                        .clear,
                        .black.opacity(0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.4), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .shadow(color: backgroundColor.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            SummaryComplaintCard(
                title: "New Complaint",
                unitCount: 13,
                complaintCount: 20,
                backgroundColor: .blue
            )
            
            SummaryComplaintCard(
                title: "In Progress",
                unitCount: 8,
                complaintCount: 15,
                backgroundColor: Color.orange.opacity(0.2)
            )
            
            SummaryComplaintCard(
                title: "Resolved",
                unitCount: 25,
                complaintCount: 45,
                backgroundColor: Color.green.opacity(0.2)
            )
            
            SummaryComplaintCard(
                title: "Pending Review",
                unitCount: 6,
                complaintCount: 12,
                backgroundColor: Color.purple.opacity(0.2)
            )
            
            SummaryComplaintCard(
                title: "Overdue",
                unitCount: 3,
                complaintCount: 7,
                backgroundColor: Color.red.opacity(0.2)
            )
            
            SummaryComplaintCard(
                title: "Total This Month",
                unitCount: 55,
                complaintCount: 99,
                backgroundColor: Color.gray.opacity(0.2)
            )
        }
        .padding(20)
    }
    
}
