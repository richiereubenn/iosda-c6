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
        NetworkManager.shared.bearerToken = "eyJhbGciOiJFZERTQSJ9.eyJ1c2VyX2lkIjoiMmI0YzU5YmQtMDQ2MC00MjZiLWE3MjAtODBjY2Q4NWVkNWIyIiwibmFtZSI6IlN1cGVyIEFkbWluaXN0cmF0b3IiLCJ1c2VybmFtZSI6InN1cGVyYWRtaW4iLCJlbWFpbCI6ImFkbWluQGV4YW1wbGUuY29tIiwicm9sZXMiOlsic3VwZXJfYWRtaW4iXSwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnBlcm1pc3Npb24iLCJjcmVhdGU6cm9sZSIsImNyZWF0ZTp1c2VyIiwiZGVsZXRlOnBlcm1pc3Npb24iLCJkZWxldGU6cm9sZSIsImRlbGV0ZTp1c2VyIiwibWFuYWdlOnJvbGVfcGVybWlzc2lvbnMiLCJyZWFkOmRlbGV0ZWRfcGVybWlzc2lvbnMiLCJyZWFkOmRlbGV0ZWRfcm9sZXMiLCJyZWFkOmRlbGV0ZWRfdXNlcnMiLCJyZWFkOnBlcm1pc3Npb24iLCJyZWFkOnBlcm1pc3Npb25zIiwicmVhZDpyb2xlIiwicmVhZDpyb2xlcyIsInJlYWQ6dXNlciIsInJlYWQ6dXNlcnMiLCJyZXN0b3JlOnBlcm1pc3Npb24iLCJyZXN0b3JlOnJvbGUiLCJyZXN0b3JlOnVzZXIiLCJ1cGRhdGU6cGVybWlzc2lvbiIsInVwZGF0ZTpyb2xlIiwidXBkYXRlOnVzZXIiXSwiaWF0IjoxNzU3MzgwMjcwLCJleHAiOjE3NTc0NjY2NzAsIm5iZiI6MTc1NzM4MDI3MCwianRpIjoiNTI4OWE1ZWItY2RlNS00YjllLTllZjYtMTRhZGFhYzdlODU3In0.6r_5P_JWDWVcFRRj3ciMZqii-dNlyW_e-8rhtGEmoyrzm-5ocWDL5hv-pxT6BX5uxpR_2LHAcJuJYYPJMiCoBA"
        
        do {
            let complaints = try await ComplaintService2().updateComplaintStatus(complaintId: "cc3cd2e7-5026-4b98-8162-261ebdf92ff0", statusId: "200635a5-68f1-4ceb-8c97-0d4cfea48119")
            apiStatus = "✅ API Connected. Found \(complaints.statusName) complaints."
        } catch {
            print("❌ API Connection failed: \(error.localizedDescription)")
            apiStatus = "❌ API Connection failed:\n\(error.localizedDescription)"
        }
    }
}

#Preview {
    APITest()
}
