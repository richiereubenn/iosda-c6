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
            NavigationStack {
                if let selection {
                    switch selection.title {
                    case "Dashboard":
                       Text("Halo")
                        
                    case "Building":
                        BuildingUnitComplainList() 
                        
                    case "Land":
                        BSCComplainDetailView()
                        
                    case "Other":
                        BuildingUnitComplainList()
                        
                    case "Unit":
                        BuildingUnitComplainList()
                        
                    case "User":
                        BuildingUnitComplainList()
                        
                    default:
                        BuildingUnitComplainList()
                    }
                } else {
                    Text("Pilih menu di sidebar")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    BSCContentView()
}

