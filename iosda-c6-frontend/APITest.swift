//
//  APITestGetUser.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 15/09/25.
//

import SwiftUI

struct APITestGetUser: View {
    @State private var apiStatus: String = "Checking API..."
    private let userService = UserService() // service yang punya getUserById

    // ganti ini dengan userId yang valid dari backend
    private let testUserId = "60d177e9-c2dc-46eb-8dd8-ba51091dc87a"

    var body: some View {
        VStack(spacing: 20) {
            Text(apiStatus)
                .font(.title2)
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear {
            Task {
                await testGetUser()
            }
        }
    }

    // MARK: - Test getUserById
    private func testGetUser() async {
        // Pakai token backend kalau perlu
        NetworkManager.shared.bearerToken = "eyJhbGciOiJFZERTQSJ9.eyJ1c2VyX2lkIjoiNjBkMTc3ZTktYzJkYy00NmViLThkZDgtYmE1MTA5MWRjODdhIiwibmFtZSI6IlN1cGVyIEFkbWluIiwidXNlcm5hbWUiOiJzdXBlcmFkbWluIiwiZW1haWwiOiJzdXBlcmFkbWluQG1haWwudGVzdCIsInJvbGVzIjpbImFkbWluIl0sInBlcm1pc3Npb25zIjpbImNyZWF0ZTphcmVhIiwiY3JlYXRlOmJsb2NrIiwiY3JlYXRlOmNsYXNzaWZpY2F0aW9uIiwiY3JlYXRlOmNvbXBsYWludCIsImNyZWF0ZTpjb250cmFjdG9yIiwiY3JlYXRlOmZpbGUiLCJjcmVhdGU6cGVybWlzc2lvbiIsImNyZWF0ZTpwcm9ncmVzcyIsImNyZWF0ZTpwcm9qZWN0IiwiY3JlYXRlOnJvbGUiLCJjcmVhdGU6c3RhdHVzIiwiY3JlYXRlOnVuaXQiLCJjcmVhdGU6dW5pdF9jb2RlIiwiY3JlYXRlOnVzZXIiLCJkZWxldGU6YXJlYSIsImRlbGV0ZTpibG9jayIsImRlbGV0ZTpjbGFzc2lmaWNhdGlvbiIsImRlbGV0ZTpjb21wbGFpbnQiLCJkZWxldGU6Y29udHJhY3RvciIsImRlbGV0ZTpmaWxlIiwiZGVsZXRlOnBlcm1pc3Npb24iLCJkZWxldGU6cHJvZ3Jlc3MiLCJkZWxldGU6cHJvamVjdCIsImRlbGV0ZTpyb2xlIiwiZGVsZXRlOnN0YXR1cyIsImRlbGV0ZTp1bml0IiwiZGVsZXRlOnVuaXRfY29kZSIsImRlbGV0ZTp1c2VyIiwibWFuYWdlOnJvbGVfcGVybWlzc2lvbnMiLCJyZWFkOmFyZWEiLCJyZWFkOmJsb2NrIiwicmVhZDpjbGFzc2lmaWNhdGlvbiIsInJlYWQ6Y29tcGxhaW50IiwicmVhZDpjb21wbGFpbnRzIiwicmVhZDpjb250cmFjdG9yIiwicmVhZDpkZWxldGVkX3Blcm1pc3Npb25zIiwicmVhZDpkZWxldGVkX3JvbGVzIiwicmVhZDpkZWxldGVkX3VzZXJzIiwicmVhZDpmaWxlIiwicmVhZDpwZXJtaXNzaW9uIiwicmVhZDpwZXJtaXNzaW9ucyIsInJlYWQ6cHJvZ3Jlc3MiLCJyZWFkOnByb2plY3QiLCJyZWFkOnJvbGUiLCJyZWFkOnJvbGVzIiwicmVhZDpzZXNzaW9uIiwicmVhZDpzZXNzaW9ucyIsInJlYWQ6c3RhdHVzIiwicmVhZDp1bml0IiwicmVhZDp1bml0X2NvZGUiLCJyZWFkOnVuaXRzIiwicmVhZDp1c2VyIiwicmVhZDp1c2VycyIsInJlc3RvcmU6cGVybWlzc2lvbiIsInJlc3RvcmU6cm9sZSIsInJlc3RvcmU6dXNlciIsInJldm9rZTpzZXNzaW9uIiwidXBkYXRlOmFyZWEiLCJ1cGRhdGU6YmxvY2siLCJ1cGRhdGU6Y2xhc3NpZmljYXRpb24iLCJ1cGRhdGU6Y29tcGxhaW50IiwidXBkYXRlOmNvbnRyYWN0b3IiLCJ1cGRhdGU6ZmlsZSIsInVwZGF0ZTpwZXJtaXNzaW9uIiwidXBkYXRlOnByb2dyZXNzIiwidXBkYXRlOnByb2plY3QiLCJ1cGRhdGU6cm9sZSIsInVwZGF0ZTpzdGF0dXMiLCJ1cGRhdGU6dW5pdCIsInVwZGF0ZTp1bml0X2NvZGUiLCJ1cGRhdGU6dXNlciJdLCJpYXQiOjE3NTc1NTU3MzMsImV4cCI6MTc1ODE2MDUzMywibmJmIjoxNzU3NTU1NzMzLCJqdGkiOiI0MDQ0ZDVhZi1mYTY0LTQ5MzItOGFiMy1mNWE1Y2FiNTRmOTkifQ.bkbLRPCxSB8GbHolitnD6fEqBkBkJeIqBRP1OMTi1op17yFGZNpfLm7cH-fMd3AgDnfV9p6MKFePYbG4w7ydDQ"

        do {
            let user = try await userService.getUserById(testUserId)
            apiStatus = """
            ✅ User found
            ID: \(user.id)
            Name: \(user.name ?? "-")
            Email: \(user.email ?? "-")
            """
        } catch {
            apiStatus = "❌ Error fetching user: \(error.localizedDescription)"
        }
    }
}

#Preview {
    APITestGetUser()
}
