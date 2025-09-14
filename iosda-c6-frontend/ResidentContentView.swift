//
//  ResidentContentView.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 08/09/25.
//

import SwiftUI

struct ResidentContentView: View {
    var body: some View {
        NavigationStack{
            ResidentHomeView(viewModel: ResidentComplaintListViewModel(), unitViewModel: ResidentUnitListViewModel())
        }
    }
}

#Preview {
    ResidentContentView()
}
