//
//  StatusBadgeView.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 01/09/25.
//


import SwiftUI

struct StatusBadge: View {
    let statusID: Status.ComplaintStatusID

    var body: some View {
        Text(statusID.displayName)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(statusID.color.opacity(0.2))
            )
    }
}
