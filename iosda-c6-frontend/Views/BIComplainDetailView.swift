//
//  BIComplainDetailView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

struct BIComplaintDetailView: View {
    let complaintId: String
    
    @State private var showRejectAlert = false
    @State private var showAcceptSheet = false
    @State private var rejectionReason = ""
    
    @StateObject private var viewModel = BSCBIComplaintDetailViewModel()
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let complaint = viewModel.selectedComplaint {
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Judul Komplain")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        GroupedCard {
                            VStack(alignment: .leading, spacing: 8) {
                                DataRowComponent(
                                    label: "Opened :",
                                    value: formatDate(complaint.createdAt, format: "dd MMM yyyy | HH:mm:ss")
                                )
                                
                                DataRowComponent(
                                    label: "Deadline :",
                                    value: formatDate(complaint.deadlineDate, format: "dd MMM yyyy | HH:mm:ss")
                                )
                                
                                HStack {
                                    Text("Status :")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                    
                                    StatusBadge(status: viewModel.selectedStatus ?? .unknown)
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Description")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                    
                                    Text(complaint.description ?? "-")
                                        .foregroundColor(.primary)
                                        .font(.system(size: 14))
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Image")
                            .font(.system(size: 18, weight: .semibold))
                        
                        GroupedCard {
                            VStack(spacing: 8) {
                                Text("Close-up view:")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                complaintImage(url: "tes")
                                
                                Text("Overall view:")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                complaintImage(url: "tes")
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location/Unit Detail")
                            .font(.system(size: 18, weight: .semibold))
                        
                        GroupedCard {
                            VStack(alignment: .leading, spacing: 8) {
                                DataRowComponent(label: "Project :", value: "-")
                                DataRowComponent(label: "Area :", value: "-")
                                DataRowComponent(label: "Block :", value: "-")
                                DataRowComponent(label: "Unit :", value: "-")
                                DataRowComponent(label: "Coordinates :", value: "-")
                            }
                        }
                    }
                    
                    actionButtons
                }
                .padding(20)
            } else {
                Text("Complaint not found")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Detail Complain")
        .background(Color(.systemGroupedBackground))
        
        .alert("Do you want to reject this issue?", isPresented: $showRejectAlert) {
            TextField("Explain why you reject this issue", text: $rejectionReason, axis: .vertical)
            
            Button("Cancel", role: .cancel) {
                rejectionReason = ""
            }
            
            Button("Reject", role: .destructive) {
                let reason = rejectionReason.trimmingCharacters(in: .whitespacesAndNewlines)
                Task {
                    await viewModel.updateStatus(to: "8e8f0a90-36eb-4a7f-aad0-ee2e59fd9b8f")
                    await viewModel.submitRejectionProgress(
                                complaintId: complaintId,
                                userId: "2b4c59bd-0460-426b-a720-80ccd85ed5b2",
                                reason: reason
                            )
                }
            }
        } message: {
            Text("Explain why you reject this issue")
        }
        
        .sheet(isPresented: $showAcceptSheet) {
            PhotoUploadSheet(
                title: "Start this Work?",
                description: "This will set the work status to\n'In Progress'.",
                photoLabel1: "A close-up photo of the specific defect.",
                photoLabel2: "A wide-angle photo showing the entire work area.",
                uploadAmount: 2,
                onStartWork: { photos in
                    Task {
                        await viewModel.updateStatus(to: "8e8f0a90-36eb-4a7f-aad0-ee2e59fd9b8f")
                        await viewModel.submitStartWorkProgress(
                            complaintId: complaintId,
                            userId: "2b4c59bd-0460-426b-a720-80ccd85ed5b2",
                            images: photos
                        )
                    }
                    showAcceptSheet = false
                },
                onCancel: {
                    showAcceptSheet = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }

        .task {
            await viewModel.loadComplaint(byId: complaintId)
        }
    }
    
    private var actionButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let status = viewModel.selectedStatus {
                switch status {
                case .inProgress:
                    HStack(spacing: 16) {
                        CustomButtonComponent(
                            text: "Reject",
                            backgroundColor: .red,
                            textColor: .white
                        ) {
                            showRejectAlert = true
                        }
                        
                        CustomButtonComponent(
                            text: "Accept",
                            backgroundColor: .primaryBlue,
                            textColor: .white
                        ) {
                            showAcceptSheet = true
                        }
                    }
                    
                case .waitingKeyHandover:
                    HStack(spacing: 16) {
                        CustomButtonComponent(
                            text: "Accept Key",
                            backgroundColor: .green,
                            textColor: .white
                        ) {
                            Task {
                                await viewModel.updateStatus(to: "ba1b0384-9c57-4c34-a70b-2ed7e44b7ce0")
                            }
                        }
                        
                        CustomButtonComponent(
                            text: "Not Receive Key",
                            backgroundColor: .red,
                            textColor: .white
                        ) {
                            Task {
                                await viewModel.updateStatus(to: "99d06c4a-e49f-4144-b617-2a1b6c51092f")
                            }
                        }
                    }
                    
                case .underReview:
                    HStack {
                        CustomButtonComponent(
                            text: "Complete Work",
                            backgroundColor: .primary,
                            textColor: .white
                        ) {
                            Task {
                                await viewModel.updateStatus(to: "c6f9c80b-1d11-4e65-8f07-d94a5a6a1d2c")
                            }
                        }
                    }
                    
                case .open, .resolved, .rejected, .closed, .unknown:
                    EmptyView()
                }
            }
        }
        .padding(.top, 12)
    }
    
    private func complaintImage(url: String?) -> some View {
        if let urlString = url, let imageURL = URL(string: urlString) {
            return AnyView(
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        VStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            Text("Failed to load image")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .cornerRadius(8)
                .clipped()
            )
        } else {
            return AnyView(
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No Image Available")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            )
        }
    }
    
    private func formatDate(_ date: Date?, format: String) -> String {
        guard let date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
