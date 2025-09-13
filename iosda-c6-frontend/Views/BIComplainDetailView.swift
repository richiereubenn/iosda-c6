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
    @State private var sheetTitle = "tes"
    @State private var sheetDescription = ""
    @State private var sheetUploadAmount = 1
    @State private var statusId = ""
    @State private var showPhotoUploadSheet = false
    @State private var showSuccessAlert = false
    @State private var successMessage = ""


    
    @StateObject private var viewModel = BSCBIComplaintDetailViewModel()
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let complaint = viewModel.selectedComplaint {
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text(complaint.title)
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
                                        .font(.subheadline)
                                    
                                    StatusBadge(status: viewModel.selectedStatus ?? .unknown)
                                    Spacer()
                                }
                                
                                DataRowComponent(
                                    label: "Kategori :",
                                    value: viewModel.classification?.name ?? "-"
                                )
                                
                                DataRowComponent(
                                    label: "Detail Kerusakan :",
                                    value: viewModel.classification?.workDetail ?? "-"
                                )
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Description")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                    
                                    Text(complaint.description ?? "-")
                                        .foregroundColor(.primary)
                                        .font(.subheadline.weight(.medium))
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
                                if viewModel.firstProgressImageURLs.isEmpty {
                                    complaintImage(url: nil) 
                                } else {
                                    ForEach(viewModel.firstProgressImageURLs.indices, id: \.self) { index in
                                        if index == 0 {
                                            Text("Close-up view:")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 14))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        } else if index == 1 {
                                            Text("Overall view:")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 14))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        
                                        complaintImage(url: viewModel.firstProgressImageURLs[index])
                                    }
                                }
                            }
                        }
                    }

                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location/Unit Detail")
                            .font(.system(size: 18, weight: .semibold))
                        
                        GroupedCard {
                            VStack(alignment: .leading, spacing: 8) {
                                DataRowComponent(label: "Project :", value: viewModel.projectName)
                                DataRowComponent(label: "Area :", value: viewModel.areaName)
                                DataRowComponent(label: "Block :", value: viewModel.blockName)
                                DataRowComponent(label: "Unit :", value: viewModel.unitName)
                                DataRowComponent(label: "Coordinates :", value: (viewModel.selectedComplaint?.latitude)!) // nanti bisa tambahkan jika ada data

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
        .alert("Progress Updated", isPresented: $showSuccessAlert, actions: {
            Button("OK", role: .cancel) { showSuccessAlert = true }
        }, message: {
            Text(successMessage)
        })

        
        .alert("Do you want to reject this issue?", isPresented: $showRejectAlert) {
            TextField("Explain why you reject this issue", text: $rejectionReason, axis: .vertical)
            
            Button("Cancel", role: .cancel) {
                rejectionReason = ""
            }
            
            Button("Reject", role: .destructive) {
                let reason = rejectionReason.trimmingCharacters(in: .whitespacesAndNewlines)
                Task {
                    await viewModel.updateStatus(to: "99d06c4a-e49f-4144-b617-2a1b6c51092f")
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
        .sheet(isPresented: $showPhotoUploadSheet) {
            PhotoUploadSheet(
                title: $sheetTitle,
                description: $sheetDescription,
                uploadAmount: $sheetUploadAmount,
                showTitleField: true,
                showDescriptionField: true,
                onStartWork: { photos, title, desc in
                    Task {
                        await viewModel.submitStartWorkProgress(
                            complaintId: complaintId,
                            userId: "fed2ef1c-4c39-4643-9207-63a201dc8562",
                            images: photos,
                            title: title ?? "",
                            description: desc ?? ""
                        )
                        await viewModel.updateStatus(to: statusId)
                        showSuccessAlert = true
                        
                        print("id complain", complaintId)
                    }
                    showPhotoUploadSheet = false
                },
                onCancel: {
                    showPhotoUploadSheet = false
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
                case .underReviewByBI:
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
                            Task{
                                await viewModel.updateStatus(to: "6272f956-8be4-4517-8b14-5e3413b79c37")
                            }
                            successMessage = "Status updated to \"Assign To Vendor\""
                            showSuccessAlert = true
                        }
                    }
                case .assignToVendor:
                    HStack {
                        CustomButtonComponent(
                            text: "Start Work",
                            backgroundColor: .primaryBlue,
                            textColor: .white
                        ) {
                            sheetTitle = "Start this Work"
                            sheetDescription = "This will set the work status to 'In Progress'."
                            sheetUploadAmount = 2
                            statusId = "ba1b0384-9c57-4c34-a70b-2ed7e44b7ce0"
                            showPhotoUploadSheet = true
                            successMessage = "Status updated to \"In Progress\""
                        }
                    }
                case .inProgress:
                    HStack {
                        CustomButtonComponent(
                            text: "Add Progress",
                            backgroundColor: .orange,
                            textColor: .white
                        ) {
                            successMessage = "New Progress Log Added"
                            showPhotoUploadSheet = true
                            sheetTitle = "Add Progress"
                            sheetDescription = "Use this to upload a progress update with photos and notes about the current work status."
                            sheetUploadAmount = 1
                        }
                        
                        CustomButtonComponent(
                            text: "Resolved",
                            backgroundColor: .primaryBlue,
                            textColor: .white
                        ) {
                            successMessage = "Status updated to \"Resolved\""
                            showPhotoUploadSheet = true
                            sheetTitle = "Complete Work"
                            sheetDescription = "This will set the work status to 'Resolved'."
                            sheetUploadAmount = 2
                            statusId = "c1eaf31c-1140-47bc-bebe-c22c62ac45e5"
                        }
                    }
                    
                case .open, .resolved, .rejected, .closed, .unknown, .underReviewbByBSC, .waitingKeyHandover:
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
