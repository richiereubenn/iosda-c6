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
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text("\(String(format: "%02d", unitCount)) Unit")
                .font(.title)
                .bold()
                .foregroundColor(.primary)

            Text("\(String(format: "%03d", complaintCount)) Complaint")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}


#Preview {
    HStack(){
        SummaryComplaintCard(
            title: "New Complaint",
            unitCount: 13,
            complaintCount: 20,
            backgroundColor: Color.blue.opacity(0.2)
        )
        .previewLayout(.sizeThatFits)
        SummaryComplaintCard(
            title: "New Complaint",
            unitCount: 13,
            complaintCount: 20,
            backgroundColor: Color.blue.opacity(0.2)
        )
        .previewLayout(.sizeThatFits)
    }
    
}
