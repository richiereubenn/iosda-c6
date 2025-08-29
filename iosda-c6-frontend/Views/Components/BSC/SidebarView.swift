//
//  SidebarView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import SwiftUI

struct MenuItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let systemImage: String
    let children: [MenuItem]?
    
    init(title: String, systemImage: String, children: [MenuItem]? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.children = children
    }
}

let sidebarMenu: [MenuItem] = [
    MenuItem(title: "Dashboard", systemImage: "square.grid.2x2"),
    MenuItem(title: "Complain", systemImage: "tray.full", children: [
        MenuItem(title: "Building", systemImage: "building.2"),
        MenuItem(title: "Land", systemImage: "leaf"),
        MenuItem(title: "Other", systemImage: "ellipsis.circle")
    ]),
    MenuItem(title: "Unit", systemImage: "square.stack.3d.up"),
    MenuItem(title: "User", systemImage: "person.2")
]

struct SidebarView: View {
    @Binding var selection: MenuItem?

    var body: some View {
        List(sidebarMenu, children: \.children, selection: $selection) { item in
            Label(item.title, systemImage: item.systemImage)
                .tag(item)
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Ciputra Help")
    }
}
