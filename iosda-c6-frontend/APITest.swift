//
//  APITest.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 08/09/25.
//

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
                await testCreateProgress()
            }
        }
    }
    
    // MARK: - Functions
    private func testCreateProgress() async {
        // Set bearer token sementara
        NetworkManager.shared.bearerToken = "eyJhbGciOiJFZERTQSJ9.eyJ1c2VyX2lkIjoiMmI0YzU5YmQtMDQ2MC00MjZiLWE3MjAtODBjY2Q4NWVkNWIyIiwibmFtZSI6IlN1cGVyIEFkbWluaXN0cmF0b3IiLCJ1c2VybmFtZSI6InN1cGVyYWRtaW4iLCJlbWFpbCI6ImFkbWluQGV4YW1wbGUuY29tIiwicm9sZXMiOlsic3VwZXJfYWRtaW4iXSwicGVybWlzc2lvbnMiOlsiY3JlYXRlOnBlcm1pc3Npb24iLCJjcmVhdGU6cm9sZSIsImNyZWF0ZTp1c2VyIiwiZGVsZXRlOnBlcm1pc3Npb24iLCJkZWxldGU6cm9sZSIsImRlbGV0ZTp1c2VyIiwibWFuYWdlOnJvbGVfcGVybWlzc2lvbnMiLCJyZWFkOmRlbGV0ZWRfcGVybWlzc2lvbnMiLCJyZWFkOmRlbGV0ZWRfcm9sZXMiLCJyZWFkOmRlbGV0ZWRfdXNlcnMiLCJyZWFkOnBlcm1pc3Npb24iLCJyZWFkOnBlcm1pc3Npb25zIiwicmVhZDpyb2xlIiwicmVhZDpyb2xlcyIsInJlYWQ6dXNlciIsInJlYWQ6dXNlcnMiLCJyZXN0b3JlOnBlcm1pc3Npb24iLCJyZXN0b3JlOnJvbGUiLCJyZXN0b3JlOnVzZXIiLCJ1cGRhdGU6cGVybWlzc2lvbiIsInVwZGF0ZTpyb2xlIiwidXBkYXRlOnVzZXIiXSwiaWF0IjoxNzU3MzgwMjcwLCJleHAiOjE3NTc0NjY2NzAsIm5iZiI6MTc1NzM4MDI3MCwianRpIjoiNTI4OWE1ZWItY2RlNS00YjllLTllZjYtMTRhZGFhYzdlODU3In0.6r_5P_JWDWVcFRRj3ciMZqii-dNlyW_e-8rhtGEmoyrzm-5ocWDL5hv-pxT6BX5uxpR_2LHAcJuJYYPJMiCoBA"
        
        do {
            let service = ProgressLogService()
            
            // 🔹 Tes create progress
            let newProgress = try await service.createProgress(
                complaintId: "3fdfd85c-e465-4440-ae16-93aea084b413",
                userId: "2b4c59bd-0460-426b-a720-80ccd85ed5b2",
                title: "Tes Progress dari iOS",
                description: "Ini deskripsi dari SwiftUI APITest",
                files: ["tes.png", "tes.png"] // bisa dicoba nil atau array string sesuai backend
            )
            
            apiStatus = "✅ Create success. Title: \(newProgress.title)"
        } catch {
            apiStatus = "❌ API Error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    APITest()
}

