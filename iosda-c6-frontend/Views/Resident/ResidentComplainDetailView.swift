import SwiftUI

struct ResidentComplainDetailView: View {
    let complaintId: String
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss
    @State private var showingProgressDetail = false
    @StateObject private var viewModel = ResidentComplaintDetailViewModel()

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let complaint = viewModel.selectedComplaint {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        // Title
                        Text(complaint.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Key handover method
                        if complaint.handoverMethod == "bring_to_mo",
                           let handoverDate = complaint.keyHandoverDate {
                            HStack(spacing: 6) {
                                Text("Key Handover Date:")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Text(formatDate(handoverDate, format: "dd MMM yyyy"))
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Status Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(spacing: 12) {
                            Text("Status")
                                .font(.title2)
                                .fontWeight(.bold)

                            StatusBadge(status: complaint.residentStatus)

                            Spacer()

                            Button("See Detail") {
                                showingProgressDetail = true
                            }
                            .foregroundColor(.blue)
                        }

                        StatusProgressBar(currentStatusName: complaint.statusName)
                    }
                    .padding(.horizontal, 20)

                    // Info if in_house
                    if complaint.handoverMethod == "in_house",
                       let openDate = complaint.openTimestamp {
                        let estimatedVisitDate = Calendar.current.date(byAdding: .day, value: 3, to: openDate)!
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("BSC will come to your house soon, no later than ")
                                .foregroundColor(.primary)
                            + Text(formatDate(estimatedVisitDate, format: "dd MMM yyyy"))
                                .bold()
                        }
                        .font(.subheadline)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                    }

                    // Detail Section
                    Text("Detail")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    GroupedCard {
                        VStack(alignment: .leading, spacing: 12) {
                            DataRowComponent(label: "ID:", value: "#\(complaint.id)")
                            DataRowComponent(label: "Complain Type:", value: complaint.classificationName ?? "Unknown")
                            DataRowComponent(label: "Created:", value: formatDate(complaint.openTimestamp ?? Date(), format: "HH:mm dd/MM/yyyy"))
                            
                            if let unitId = complaint.unitId {
                                DataRowComponent(label: "Unit ID:", value: unitId)
                            }

                            if let closeTimestamp = complaint.closeTimestamp {
                                DataRowComponent(label: "Closed", value: formatDate(closeTimestamp, format: "HH:mm dd/MM/yyyy"))
                            }

                            if !complaint.description.isEmpty {
                                DataRowComponent(label: "Description:", value: "")
                                Text(complaint.description)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    //.padding(.top, 8)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Image Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Image")
                            .font(.title2)
                            .fontWeight(.bold)

                        GroupedCard {
                            VStack(spacing: 8) {
                                ForEach(viewModel.firstProgressImageURLs.prefix(2).indices, id: \.self) { index in
                                    let label = index == 0 ? "Close-up view:" : "Overall view:"
                                    Text(label)
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    complaintImage(url: viewModel.firstProgressImageURLs[index])
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 100)
                }
            } else {
                Text("Complaint not found")
                    .foregroundColor(.secondary)
            }
        }

        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
            }
        }

        .navigationDestination(isPresented: $showingProgressDetail) {
            if let complaint = viewModel.selectedComplaint {
                ResidentProgressDetailView(complaintId: complaint.id)
            }
        }

        .overlay(alignment: .bottom) {
            if let complaint = viewModel.selectedComplaint,
               let status = complaint.statusName?.lowercased(),
               let method = complaint.handoverMethod,
               (status == "under review by bi" || status == "waiting key handover") && method == "bring_to_mo" {
                VStack(spacing: 0) {
                    CustomButtonComponent(
                        text: "Submit Key Handover Evidence",
                        action: {
                            // TODO: Handle evidence submission
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .background(Color(.systemBackground))
                }
            }
        }

        .task {
            await viewModel.loadComplaint(byId: complaintId)
            await viewModel.getProgressLogs(complaintId: complaintId)
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

    private func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
