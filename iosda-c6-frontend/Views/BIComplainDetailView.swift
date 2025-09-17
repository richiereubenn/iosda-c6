//
//  BIComplainDetailView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

struct BIComplaintDetailView: View {
    let complaintId: String
    let complaintName: String
    
    @State private var showRejectAlert = false
    @State private var showAcceptSheet = false
    @State private var rejectionReason = ""
    @State private var sheetTitle = "Test"
    @State private var sheetDescription = ""
    @State private var sheetUploadAmount = 1
    @State private var statusId = ""
    @State private var showPhotoUploadSheet = false
    @State private var showSuccessAlert = false
    @State private var successMessage = ""

    @StateObject private var viewModel = BSCBIComplaintDetailViewModel()
    
    var body: some View {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                    } else if let complaint = viewModel.selectedComplaint {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                
                                // MARK: Complaint Header
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Details")
                                        .font(.system(size: 18, weight: .semibold))
                                    GroupedCard {
                                        VStack(alignment: .leading, spacing: 8) {
                                            DataRowComponent(
                                                label: "Title:",
                                                value: complaint.title ?? "-"
                                            )
                                            DataRowComponent(
                                                label: "Opened:",
                                                value: complaint.createdAt.map { formatDate($0, format: "HH:mm dd/MM/yyyy") } ?? "-"
                                            )
                                            
                                            DataRowComponent(
                                                label: "Deadline:",
                                                value: complaint.duedate.map { formatDate($0, format: "HH:mm dd/MM/yyyy") } ?? "-"
                                            )

                                            HStack {
                                                Text("Status:")
                                                    .foregroundColor(.gray)
                                                    .font(.subheadline)
                                                
                                                StatusBadge(status: viewModel.selectedStatus ?? .unknown)
                                                Spacer()
                                            }
                                            
                                            // MARK: Category & Damage Detail with Loading Handling
                                            if viewModel.isLoading {
                                                DataRowComponent(label: "Category:", value: "Loading...")
                                                DataRowComponent(label: "Damage Details:", value: "Loading...")
                                            } else {
                                                DataRowComponent(
                                                    label: "Category:",
                                                    value: viewModel.classification?.name ?? "-"
                                                )
                                                
                                                DataRowComponent(
                                                    label: "Work Details:",
                                                    value: viewModel.classification?.workDetail ?? "-"
                                                )
                                            }
                                        }
                                    }
                                }
                                
                                // MARK: Images Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Images")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    GroupedCard {
                                        VStack(spacing: 8) {
                                            if viewModel.isLoading {
                                                ProgressView()
                                                    .frame(height: 150)
                                                    .frame(maxWidth: .infinity)
                                            } else if viewModel.firstProgressImageURLs.isEmpty {
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

                                // MARK: Unit Details
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Location / Unit Details")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    GroupedCard {
                                        VStack(alignment: .leading, spacing: 8) {
                                            DataRowComponent(label: "Project:", value: viewModel.projectName)
                                            DataRowComponent(label: "Area:", value: viewModel.areaName)
                                            DataRowComponent(label: "Block:", value: viewModel.blockName)
                                            DataRowComponent(label: "Unit:", value: viewModel.unitName)
                                        }
                                    }
                                }
                                
                                // MARK: Actions
                                actionButtons
                            }
                            .padding(20)
                        }
                    } else {
                        Text("Complaint not found")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .navigationTitle(complaintName)

            // MARK: Success Alert
            .alert("Progress Updated", isPresented: $showSuccessAlert, actions: {
                Button("OK", role: .cancel) { showSuccessAlert = true }
            }, message: {
                Text(successMessage)
            })

            // MARK: Reject Alert
            .alert("Do you want to reject this issue?", isPresented: $showRejectAlert) {
                TextField("Enter the reason for rejection", text: $rejectionReason, axis: .vertical)
                
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
                Text("Please provide a reason for rejecting this issue.")
            }
            
            // MARK: Photo Upload Sheet
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
                            
                            if sheetTitle == "Start Work" {
                                await viewModel.updateDueDateForStartWork()
                            }
                            showSuccessAlert = true
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
                            sheetTitle = "Start Work"
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
                            sheetTitle = "New Progress"
                            successMessage = "New Progress Log Added"
                            showPhotoUploadSheet = true
                            sheetDescription = "Upload progress updates with photos and notes about the current work status."
                            statusId = "ba1b0384-9c57-4c34-a70b-2ed7e44b7ce0"
                            sheetUploadAmount = 1
                        }
                        
                        CustomButtonComponent(
                            text: "Resolved",
                            backgroundColor: .primaryBlue,
                            textColor: .white
                        ) {
                            sheetTitle = "Task Resolved"
                            successMessage = "Status updated to \"Resolved\""
                            showPhotoUploadSheet = true
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
