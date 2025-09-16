//
//  Color.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 31/08/25.
//

import SwiftUI

extension Color {
    static let logoGreen = Color(red: 18/255, green: 152/255, blue: 116/255)
    static let primaryBlue = Color(red: 0/255, green: 62/255, blue: 126/255)
    static var cardBackground: Color {
            let scheme = UITraitCollection.current.userInterfaceStyle
        return scheme == .dark ? Color(.secondarySystemBackground)
        : Color(.systemBackground)
    }
}
