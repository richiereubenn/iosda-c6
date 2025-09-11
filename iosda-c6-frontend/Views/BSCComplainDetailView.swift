//
//  BSCComplainDetailView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 31/08/25.
//

import SwiftUI

struct BSCComplainDetailView: View {
    let complaintId: String
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    @StateObject private var viewModel = BSCBIComplaintDetailViewModel()
    
    @State private var garansiChecked = true
    @State private var izinRenovasiChecked = true
    @State private var showRejectAlert = false
    @State private var rejectionReason = ""

    
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
                            Text("Complain Description")
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
        .navigationTitle("Detail Complain")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadComplaint(byId: complaintId)
            await viewModel.loadClassifications(defaultId: "75b125fd-a656-4fd8-a500-2f051b068171")
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
                Text("Explain why you reject this issue")
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
            Text("Residence Profile")
                .font(.headline)
            GroupedCard {
                VStack(spacing: 5) {
                    DataRowComponent(label: "Nama:", value: "–")
                    DataRowComponent(label: "Nomor HP:", value: "–")
                    DataRowComponent(label: "Kode Rumah:", value: "–")
                    DataRowComponent(label: "Tanggal ST:", value: "-")
                }
            }
        }
    }
    
    private func statusComplain(complaint: Complaint2) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status Complain")
                .font(.headline)
            GroupedCard {
                VStack(spacing: 5) {
                    DataRowComponent(
                        label: "Tanggal Masuk:",
                        value: formatDate(complaint.openTimestamp ?? Date(), format: "HH:mm dd/MM/yyyy")
                    )
                    HStack {
                        Text("Status:")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        StatusBadge(status: viewModel.selectedStatus ?? .unknown)
                        Spacer()
                    }
                    DataRowComponent(
                        label: "Key Method:",
                        value: complaint.handoverMethod ?? "-"
                    )
                    DataRowComponent(
                        label: "Deadline:",
                        value: formatDate(complaint.deadlineDate ?? Date(), format: "HH:mm dd/MM/yyyy")
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
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline) {
                Text("Kategori : ")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                if viewModel.uniqueCategories.isEmpty {
                        Text("Loading categories...")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Pilih Kategori", selection: $viewModel.selectedCategory) {
                            ForEach(viewModel.uniqueCategories, id: \.self) { category in
                                Text(category).tag(category as String?)
                                    .font(.footnote.weight(.medium))
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: viewModel.selectedCategory) { _ in
                            viewModel.selectedWorkDetail = nil
                        }
                    }
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text("Detail Kerusakan : ")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                if viewModel.workDetailsForSelectedCategory.isEmpty {
                        Text("Loading categories...")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Pilih Detail Kerusakan", selection: $viewModel.selectedWorkDetail) {
                            Text("Pilih Detail Kerusakan").tag(nil as String?)
                            ForEach(viewModel.workDetailsForSelectedCategory, id: \.self) { detail in
                                Text(detail).tag(detail as String?)
                                    .font(.subheadline.weight(.medium))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        .pickerStyle(.menu)
                        .disabled(viewModel.selectedCategory == nil)
                        .frame(maxWidth: 200, alignment: .leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    }
                
                
            }
            
            Text(complaint.description ?? "–")
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    
    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Syarat").font(.headline)
            GroupedCard {
                VStack(spacing: 5) {
                    RequirementsCheckbox(
                        text: "Garansi",
                        isChecked: garansiChecked,
                        onToggle: { garansiChecked.toggle() }
                    )
                    RequirementsCheckbox(
                        text: "Izin Renovasi",
                        isChecked: izinRenovasiChecked,
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
                            await viewModel.updateStatus(to: "8e8f0a90-36eb-4a7f-aad0-ee2e59fd9b8f")
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
