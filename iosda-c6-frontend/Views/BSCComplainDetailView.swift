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
                            actionButtons
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
        VStack(alignment: .leading, spacing: 12) {
            DataRowComponent(label: "Kategori:", value: "–")
            DataRowComponent(label: "Detail Kerusakan:", value: "–")
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
    
    private var actionButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let status = viewModel.selectedStatus {
                switch status {
                case .underReview:
                    CustomButtonComponent(
                        text: "Confirm",
                        backgroundColor: .primaryBlue,
                        textColor: .white,
                        isDisabled: isConfirmDisabled
                    ) {
                        Task {
                            await viewModel.updateStatus(to: "8e8f0a90-36eb-4a7f-aad0-ee2e59fd9b8f")
                            NotificationManager.shared.sendNotification(
                                title: "Complain Confirmed",
                                body: "You have confirmed the complain."
                            )
                        }
                    }
                    
                case .waitingKeyHandover:
                    HStack(spacing: 12) {
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
                    
                case .inProgress:
                    HStack(spacing: 12) {
                    }
                    
                case .open, .resolved, .rejected, .unknown, .closed:
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
