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
                    BSCBuildingUnitComplainListView()
                    
                case "Land":
                    Text("Land")
                    
                case "Other":
                    //Text("Other")
                    LoginView()
                    
                case "Unit":
                    BSCUnitListView()
                    
                case "Resident View":
                    NavigationStack{
                        ResidentHomeView(viewModel: ResidentComplaintListViewModel(), unitViewModel: UnitViewModel(), userId: "2b4c59bd-0460-426b-a720-80ccd85ed5b2")
                    }
                    
                case "BI View":
                    BIContentView()
                    
                default:
                    BSCBuildingUnitComplainListView()
                }
            } else {
                BSCBuildingUnitComplainListView()
            }
            
        }
    }
}

//#Preview {
//    BSCContentView(complaintId: complaintId)
//}

