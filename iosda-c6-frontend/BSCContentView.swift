//
//  BSCContentView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import SwiftUI

struct BSCContentView: View {
    @State private var selection: MenuItem?

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } detail: {
            if let selection {
                switch selection.title {
                case "Dashboard":
                    Text("Dashboard")
                case "Building":
                    BuildingUnitComplainList()
                case "Land":
                    Text("Land")
                case "Other":
                    Text("Other")
                case "Unit":
                    Text("Unit")
                case "User":
                    Text("User")
                default:
                    Text("Halaman: \(selection.title)")
                        .font(.largeTitle)
                        .bold()
                }
            } else {
                Text("Pilih menu di sidebar")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
    }
}


#Preview {
    BSCContentView()
}

