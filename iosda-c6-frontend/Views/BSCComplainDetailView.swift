//
//  BSCComplainDetailView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 31/08/25.
//

import SwiftUI

struct BSCComplainDetailView: View {
    let complaintId: String
    let complainName: String
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    @StateObject private var viewModel = BSCBIComplaintDetailViewModel()
    
    @State private var garansiChecked = true
    @State private var izinRenovasiChecked = true
    @State private var showRejectAlert = false
    @State private var rejectionReason = ""
    @State private var showSuccessAlert = false
    
    
    private var isConfirmDisabled: Bool {
        !(garansiChecked && izinRenovasiChecked)
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let complaint = viewModel.selectedComplaint {
                    ScrollView {
                        VStack(spacing: 20) {
                            headerSection(complaint: complaint)
                            Text("Complaint Description")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            detailsSection(complaint: complaint)
                            requirementsSection
                            actionButtons(complaint: complaint)
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    Text("Complaint not found")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(complainName)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadComplaint(byId: complaintId)
            await viewModel.loadClassifications(defaultId: viewModel.classification?.id)
        }
        .alert("Complaint Confirmed Successfully", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { showSuccessAlert = false }
        }
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
            Text("Please explain the reason for rejection")
        }
    }
    
    
    
    private func headerSection(complaint: Complaint2) -> some View {
        Group {
            if sizeClass == .regular {
                HStack(spacing: 40) {
                    residenceProfile(complaint: complaint)
                    statusComplain(complaint: complaint)
                }
            } else {
                VStack(spacing: 20) {
                    residenceProfile(complaint: complaint)
                    statusComplain(complaint: complaint)
                }
            }
        }
    }
    
    private func residenceProfile(complaint: Complaint2) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resident Profile")
                .font(.headline)
            GroupedCard {
                VStack(spacing: 5) {
                    DataRowComponent(
                        label: "Name:",
                        value: viewModel.resident?.name ?? "–"
                    )
                    DataRowComponent(
                        label: "Phone Number:",
                        value: viewModel.resident?.phone ?? "–"
                    )
                    DataRowComponent(
                        label: "House Code:",
                        value: viewModel.unit?.unitNumber ?? "–"
                    )
                    DataRowComponent(
                        label: "Handover Date:",
                        value: viewModel.unit?.handoverDate.map {
                            formatDate($0, format: "dd/MM/yyyy")
                        } ?? "-"
                    )
                }
            }
        }
    }
    
    private func statusComplain(complaint: Complaint2) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Complaint Status")
                .font(.headline)
            GroupedCard {
                VStack(spacing: 5) {
                    DataRowComponent(
                        label: "Submitted At:",
                        value: complaint.createdAt.map { formatDate($0, format: "HH:mm dd/MM/yyyy") } ?? "-"
                    )
                    
                    HStack {
                        Text("Status:")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        StatusBadge(status: viewModel.selectedStatus ?? .unknown)
                        Spacer()
                    }
                    DataRowComponent(
                        label: "Key Handover Method:",
                        value: complaint.handoverMethod?.displayName ?? "-"
                    )
                    DataRowComponent(
                        label: "Deadline:",
                        value: complaint.duedate.map { formatDate($0, format: "HH:mm dd/MM/yyyy") } ?? "-"
                    )
                }
            }
        }
    }
    
    private func detailsSection(complaint: Complaint2) -> some View {
        Group {
            if sizeClass == .regular {
                GroupedCard {
                    HStack(alignment: .top, spacing: 20) {
                        complainImages(for: complaint)
                        complainDetails(complaint: complaint)
                    }
                }
            } else {
                GroupedCard {
                    VStack(spacing: 20) {
                        complainImages(for: complaint)
                        complainDetails(complaint: complaint)
                    }
                }
            }
        }
    }
    
    private func complainImages(for complaint: Complaint2) -> some View {
        let urls = viewModel.firstProgressImageURLs
        return Group {
            if sizeClass == .regular {
                VStack(spacing: 12) {
                    ForEach(urls, id: \.self) { url in
                        complaintImage(url: url)
                    }
                }
            } else {
                HStack(spacing: 12) {
                    ForEach(urls, id: \.self) { url in
                        complaintImage(url: url)
                    }
                    Spacer()
                }
            }
        }
    }
    
    
    private func complaintImage(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle().fill(Color.gray.opacity(0.3))
        }
        .frame(width: 150, height: 100)
        .cornerRadius(8)
        .clipped()
    }
    
    private func complainDetails(complaint: Complaint2) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                if complaint.statusName?.lowercased() != "under review by bsc" {
                    if let savedClassification = viewModel.classification {
                        DataRowComponent(
                            label: "Category: ",
                            value: savedClassification.name
                        )
                    } else {
                        Text("-")
                    }
                } else {
                    Text("Category: ")
                        .font(.subheadline)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .foregroundColor(.gray)
                    
                    if viewModel.uniqueCategories.isEmpty {
                        Text("Loading categories...")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Select Category", selection: $viewModel.selectedCategory) {
                            ForEach(viewModel.uniqueCategories, id: \.self) { category in
                                Text(category).tag(category as String?)
                            }
                        }
                        .pickerStyle(.menu)
                        .scaleEffect(0.9)
                        .accentColor(.primaryBlue)
                        .fixedSize()
                        .padding(.leading, -20)
                        .padding(.bottom, -20)
                        .padding(.top, -15)
                        .disabled(viewModel.selectedCategory == nil)
                        .onChange(of: viewModel.selectedCategory) { _ in
                            viewModel.selectedWorkDetail = nil
                        }
                    }
                }
            }
            
            HStack(alignment: .firstTextBaseline) {
                if complaint.statusName?.lowercased() != "under review by bsc" {
                    if let savedClassification = viewModel.classification {
                        DataRowComponent(
                            label: "Damage Detail: ",
                            value: savedClassification.workDetail ?? "-"
                        )
                    } else {
                        Text("-")
                    }
                } else {
                    Text("Work Detail: ")
                        .font(.subheadline)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .foregroundColor(.gray)
                    
                    if viewModel.workDetailsForSelectedCategory.isEmpty {
                        Text("Loading details...")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Select Damage Detail", selection: $viewModel.selectedWorkDetail) {
                            Text("Select Damage Detail").tag(nil as String?)
                            ForEach(viewModel.workDetailsForSelectedCategory, id: \.self) { detail in
                                Text(detail).tag(detail as String?)
                            }
                        }
                        .pickerStyle(.menu)
                        .scaleEffect(0.9)
                        .accentColor(.primaryBlue)
                        .fixedSize()
                        .padding(.leading, -25)
                        .padding(.top, -15)
                        .padding(.bottom, -15)
                        .disabled(viewModel.selectedCategory == nil)
                    }
                }
            }
            Text(complaint.description ?? "–")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    
    
    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Requirements").font(.headline)
            GroupedCard {
                VStack(spacing: 5) {
                    RequirementsCheckbox(
                        text: "Warranty",
                        isChecked: viewModel.selectedComplaint != nil ?
                        viewModel.unit != nil && viewModel.classification != nil ?
                        BSCBuildingUnitComplainListViewModel().isWarrantyValid(
                            for: viewModel.selectedComplaint!,
                            unit: viewModel.unit,
                            classification: viewModel.classification
                        ) : false
                        : false,
                        onToggle: { garansiChecked.toggle() }
                    )
                    RequirementsCheckbox(
                        text: "Renovation Permit",
                        isChecked: viewModel.unit?.renovationPermit ?? false,
                        onToggle: { izinRenovasiChecked.toggle() }
                    )
                }
            }
        }
    }
    
    private func actionButtons(complaint: Complaint2) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let status = viewModel.selectedStatus {
                switch status {
                case .underReviewbByBSC:
                    CustomButtonComponent(
                        text: "Confirm",
                        backgroundColor: .primaryBlue,
                        textColor: .white,
                        isDisabled: isConfirmDisabled
                    ) {
                        Task {
                            await viewModel.updateClassification()
                            await viewModel.updateStatus(to: "8e8f0a90-36eb-4a7f-aad0-ee2e59fd9b8f")
                            
                            showSuccessAlert = true
                            let progressService = ProgressLogService()
                            do {
                                _ = try await progressService.createProgress(
                                    complaintId: complaintId,
                                    userId: "376db8a1-b5e0-4c97-a277-e18e46237921", // ganti dengan user id yang sesuai
                                    title: "Complaint Confirmed Successfully",
                                    description: "The complaint has been reviewed and accepted."
                                )
                            } catch {
                                print("Failed to create progress log: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                case .open, .resolved, .rejected, .unknown, .closed, .assignToVendor, .underReviewByBI, .waitingKeyHandover, .inProgress:
                    EmptyView()
                }
            }
        }
    }
    
    
    private func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
