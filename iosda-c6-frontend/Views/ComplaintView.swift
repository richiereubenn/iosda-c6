//
//  ComplaintView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 29/08/25.
//

import SwiftUI

struct ComplaintView: View {
    @StateObject private var viewModel = ComplaintViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading && viewModel.complaints.isEmpty {
                    ProgressView("Memuat komplain...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.complaints) { complaint in
                            ComplaintRowView(complaint: complaint)
                        }
                    }
                    .refreshable {
                        await viewModel.refreshComplaints()
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Terjadi kesalahan:")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        PrimaryButton(
                            title: "Coba Lagi",
                            action: {
                                Task {
                                    await viewModel.loadComplaints()
                                }
                            }
                        )
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("Daftar Komplain")
            .task {
                await viewModel.loadComplaints()
            }
        }
    }
}

struct ComplaintRowView: View {
    let complaint: Complaint
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(complaint.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                StatusBadge(status: complaint.status)
            }
            
            Text(complaint.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Label(complaint.category, systemImage: "tag.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if let createdAt = complaint.createdAt {
                    Text(createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: Complaint.ComplaintStatus
    
    var backgroundColor: Color {
        switch status {
        case .pending: return .orange
        case .inProgress: return .blue
        case .resolved: return .green
        case .rejected: return .red
        }
    }
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.2))
            .foregroundColor(backgroundColor)
            .cornerRadius(8)
    }
}


#Preview {
    ComplaintView()
}
