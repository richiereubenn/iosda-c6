//
//  ComplainListView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 31/08/25.
//

import SwiftUI

struct ComplainListView: View {
    @StateObject private var viewModel = BuildingListViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
        }
        .padding(.top)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { viewModel.sortOption = .latest }) {
                        Label("Tanggal Terbaru", systemImage: viewModel.sortOption == .latest ? "checkmark" : "")
                    }
                    Button(action: { viewModel.sortOption = .oldest }) {
                        Label("Tanggal Terlama", systemImage: viewModel.sortOption == .oldest ? "checkmark" : "")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title2)
                        .foregroundColor(Color.primaryBlue)
                }
            }
        }
        .navigationTitle("Nomor Rumah")
        .searchable(text: $viewModel.searchText)
        
    }
}


#Preview {
    ComplainListView()
}
