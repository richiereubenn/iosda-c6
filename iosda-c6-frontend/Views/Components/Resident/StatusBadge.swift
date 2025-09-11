//
//  StatusBadgeView.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 01/09/25.
//


import SwiftUI

struct StatusBadge: View {
    let status: ComplaintStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption.weight(.bold))
            .padding(6)
            .background(status.color.opacity(0.2))
            .foregroundColor(status.color)
            .cornerRadius(8)
    }
}
