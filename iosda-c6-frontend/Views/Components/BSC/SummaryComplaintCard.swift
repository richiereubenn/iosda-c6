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

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    private var isVeryCompact: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .compact
    }

    var body: some View {
        VStack(spacing: isVeryCompact ? 8 : isCompact ? 12 : 16) {
            HStack(spacing: isCompact ? 8 : 12) {
                Text(title)
                    .font(.headline) 
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(isVeryCompact ? 1 : 2)
                    .minimumScaleFactor(0.8)
            }
            
            VStack(spacing: isVeryCompact ? 6 : isCompact ? 8 : 12) {
                HStack {
                    Image(systemName: "building.2.fill")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(width: isVeryCompact ? 20 : 24)
                    
                    Text("\(String(format: "%02d", unitCount)) Unit")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.7)
                }
                
                HStack {
                    Image(systemName: "list.bullet.clipboard.fill")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(width: isVeryCompact ? 20 : 24)
                    
                    Text("\(String(format: "%03d", complaintCount)) Complaint")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(.horizontal, isCompact ? 2 : 4)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, isVeryCompact ? 16 : isCompact ? 20 : 24)
        .padding(.horizontal, isVeryCompact ? 12 : isCompact ? 16 : 20)
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
        .cornerRadius(isVeryCompact ? 12 : isCompact ? 14 : 16)
        .overlay(
            RoundedRectangle(cornerRadius: isVeryCompact ? 12 : isCompact ? 14 : 16)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.4), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: .black.opacity(0.08), radius: isCompact ? 6 : 8, x: 0, y: 4)
        .shadow(color: backgroundColor.opacity(0.2), radius: isCompact ? 8 : 12, x: 0, y: 6)
    }
}
