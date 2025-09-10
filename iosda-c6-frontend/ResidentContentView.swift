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
            ResidentHomeView(viewModel: ResidentComplaintListViewModel(), unitViewModel: UnitViewModel(), userId: "2b4c59bd-0460-426b-a720-80ccd85ed5b2")
        }
    }
}

#Preview {
    ResidentContentView()
}
