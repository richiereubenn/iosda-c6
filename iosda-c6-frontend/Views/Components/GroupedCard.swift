//
//  GroupedCard.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 04/09/25.
//

import SwiftUI


struct GroupedCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05),
                    radius: 4, x: 0, y: 2)
    }
}

