//
//  UnitStatusSummaryCard.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 02/09/25.
//

import SwiftUI

struct UnitStatusSummaryCard: View {
    let title: String
    let count: Int
    let backgroundColor: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            Text(title)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text("\(count)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 65)
        .padding(.vertical, 35)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        backgroundColor,
                        backgroundColor.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                LinearGradient(
                    colors: [
                        .white.opacity(0.1),
                        .clear,
                        .black.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(20)
        .shadow(
            color: backgroundColor.opacity(0.3),
            radius: 8,
            x: 0,
            y: 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct UnitStatusSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                UnitStatusSummaryCard(
                    title: "Unit Aktif",
                    count: 24,
                    backgroundColor: .green,
                    icon: "checkmark.circle.fill"
                )
                
                UnitStatusSummaryCard(
                    title: "Unit Maintenance",
                    count: 8,
                    backgroundColor: .orange,
                    icon: "wrench.and.screwdriver.fill"
                )
                
                UnitStatusSummaryCard(
                    title: "Unit Rusak",
                    count: 3,
                    backgroundColor: .red,
                    icon: "exclamationmark.triangle.fill"
                )
                
                UnitStatusSummaryCard(
                    title: "Total Unit",
                    count: 35,
                    backgroundColor: .blue,
                    icon: "square.stack.3d.up.fill"
                )
                
                UnitStatusSummaryCard(
                    title: "Unit Standby",
                    count: 12,
                    backgroundColor: .purple,
                    icon: "pause.circle.fill"
                )
                
                UnitStatusSummaryCard(
                    title: "Unit Dalam Perjalanan",
                    count: 6,
                    backgroundColor: .teal,
                    icon: "location.fill"
                )
            }
            .padding(20)
        }
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        .previewDisplayName("iPad Pro 12.9\"")
        
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                UnitStatusSummaryCard(
                    title: "Unit Aktif",
                    count: 24,
                    backgroundColor: .green,
                    icon: "checkmark.circle.fill"
                )
                
                UnitStatusSummaryCard(
                    title: "Unit Maintenance",
                    count: 8,
                    backgroundColor: .orange,
                    icon: "wrench.and.screwdriver.fill"
                )
            }
            .padding(16)
        }
        .previewDevice("iPhone 15 Pro")
        .previewDisplayName("iPhone 15 Pro")
    }
}
