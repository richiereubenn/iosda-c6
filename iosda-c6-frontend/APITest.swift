//
//  APITest.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 08/09/25.
//

import SwiftUI


import SwiftUI

struct APITest: View {
    @State private var apiStatus: String = "Checking API..."
    
    var body: some View {
        VStack(spacing: 20) {
            Text(apiStatus)
                .font(.title2)
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear {
            Task {
                await checkAPI()
            }
        }
    }
    
    // MARK: - Functions
    private func checkAPI() async {
        // Set bearer token di NetworkManager (sementara)
        NetworkManager.shared.bearerToken = "eyJhbGciOiJFZERTQSJ9.eyJ1c2VyX2lkIjoiMmI0YzU5YmQtMDQ2MC00MjZiLWE3MjAtODBjY2Q4NWVkNWIyIiwibmFtZSI6IlN1cGVyIEFkbWluaXN0cmF0b3IiLCJ1c2VybmFtZSI6InN1cGVyYWRtaW4iLCJlbWFpbCI6ImFkbWluQGV4YW1wbGUuY29tIiwicm9sZXMiOlsic3VwZXJfYWRtaW4iXSwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnBlcm1pc3Npb24iLCJjcmVhdGU6cm9sZSIsImNyZWF0ZTp1c2VyIiwiZGVsZXRlOnBlcm1pc3Npb24iLCJkZWxldGU6cm9sZSIsImRlbGV0ZTp1c2VyIiwibWFuYWdlOnJvbGVfcGVybWlzc2lvbnMiLCJyZWFkOmRlbGV0ZWRfcGVybWlzc2lvbnMiLCJyZWFkOmRlbGV0ZWRfcm9sZXMiLCJyZWFkOmRlbGV0ZWRfdXNlcnMiLCJyZWFkOnBlcm1pc3Npb24iLCJyZWFkOnBlcm1pc3Npb25zIiwicmVhZDpyb2xlIiwicmVhZDpyb2xlcyIsInJlYWQ6dXNlciIsInJlYWQ6dXNlcnMiLCJyZXN0b3JlOnBlcm1pc3Npb24iLCJyZXN0b3JlOnJvbGUiLCJyZXN0b3JlOnVzZXIiLCJ1cGRhdGU6cGVybWlzc2lvbiIsInVwZGF0ZTpyb2xlIiwidXBkYXRlOnVzZXIiXSwiaWF0IjoxNzU3Mjk4NDIxLCJleHAiOjE3NTczODQ4MjEsIm5iZiI6MTc1NzI5ODQyMSwianRpIjoiZjQ0ODc2OTMtNzhkOC00MWZhLTkyYzgtZWZmOTVhZWIwMmM5In0.xvNxOI3vTEJnBpg-o8Xgr2L0snqlKrcHQKGtG0T79xwAoOV1wPrImbi0PPHwdizXbDOoiLQReNDDwg4cTQI_CA"
        
        do {
            let complaints = try await ComplaintService2().fetchComplaints()
            print("✅ API Connection successful. Complaints count: \(complaints.count)")
            apiStatus = "✅ API Connected. Found \(complaints.count) complaints."
        } catch {
            print("❌ API Connection failed: \(error.localizedDescription)")
            apiStatus = "❌ API Connection failed:\n\(error.localizedDescription)"
        }
    }
}

#Preview {
    APITest()
}
