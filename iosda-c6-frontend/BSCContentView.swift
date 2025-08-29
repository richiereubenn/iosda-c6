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
                    Text("Kontol")
                case "Building":
                    BuildingComplainListView()
                case "Land":
                    BuildingComplainListView()
                case "Other":
                    BuildingComplainListView()
                case "Unit":
                    BuildingComplainListView()
                case "User":
                    BuildingComplainListView()
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

