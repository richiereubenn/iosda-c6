import SwiftUI

struct ResidentComplainDetailView: View {
    let complaintId: String
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss
    @State private var showingProgressDetail = false
    @ObservedObject var viewModel = ResidentComplaintDetailViewModel()
    @State private var showingPhotoUpload = false
    private let progressLogService = ProgressLogService()



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
                            .padding(.horizontal)
                        
                            
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
                                    .foregroundColor(.primaryBlue)
                                }
                                
                                StatusProgressBar(currentStatusName: complaint.statusName)
                            }
                            .padding(.horizontal, 20)
                            
                            // Info if in_house
                            if complaint.handoverMethod == .inHouse,
                               let openDate = complaint.openTimestamp {
                                let estimatedVisitDate = Calendar.current.date(byAdding: .day, value: 3, to: openDate)!
                                GroupedCard {
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.primaryBlue)
                                        Text("BSC will come to your house soon, no later than ")
                                            .foregroundColor(.primary)
                                        + Text(formatDate(estimatedVisitDate, format: "dd MMM yyyy"))
                                            .bold()
                                    }
                                    .font(.subheadline)
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            if complaint.handoverMethod == .bringToMO,
                               let handoverDate = viewModel.selectedUnit?.keyHandoverDate {
                                GroupedCard {
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.primaryBlue)
                                        Text("Please hand over your key on ")
                                            .foregroundColor(.primary)
                                        + Text(formatDate(handoverDate, format: "dd MMM yyyy"))
                                            .bold()
                                        + Text(" for us to start working on the complaint.")
                                            .foregroundColor(.primary)
                                    }
                                    .font(.subheadline)
                                }
                                .padding(.horizontal, 20)
                            }

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
                            
                            if let unit = viewModel.selectedUnit {
                                DataRowComponent(label: "Unit:", value: unit.name ?? "Unit")
                            }

                            if let closeTimestamp = complaint.closeTimestamp {
                                DataRowComponent(label: "Closed", value: formatDate(closeTimestamp, format: "HH:mm dd/MM/yyyy"))
                            }

                            if !complaint.description.isEmpty {
                                DataRowComponent(label: "Description:", value: "")

                                let parts = complaint.description.components(separatedBy: "\n\nAdditional Notes:\n")
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    // Main description
                                    Text(parts.first ?? "")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    // Additional notes (if available)
                                    if parts.count > 1, !parts[1].isEmpty {
                                        DataRowComponent(
                                            label: "Additional Notes:",
                                            value: parts[1],
                                            labelColor: .secondary,
                                            valueColor: .gray
                                        )
                                    }
                                }
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
                    .foregroundColor(.primaryBlue)
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
               complaint.handoverMethod == .bringToMO,
               complaint.residentStatus == .waitingKeyHandover{
              // !viewModel.hasSubmittedKeyLog {   

                VStack(spacing: 0) {
                    CustomButtonComponent(
                        text: "Submit Key Handover Evidence",
                        backgroundColor: .primaryBlue
                    ) {
                        showingPhotoUpload = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .background(Color(.systemBackground))
                }
            }
        }


        .sheet(isPresented: $showingPhotoUpload) {
            PhotoUploadSheet(
                title: .constant("Key Handover Evidence"),
                description: .constant("Please provide a description of the key handover."),
                uploadAmount: .constant(1),
                showTitleField: false,
                showDescriptionField: true,
                onStartWork: { images, _, description in
                    Task {
                        guard let complaint = viewModel.selectedComplaint else { return }
                        guard let userId = NetworkManager.shared.getUserIdFromToken() else {
                            
                            return
                        }

                        // ✅ Get unitId from the complaint
                        guard let unitId = complaint.unitId else {
                            
                            return
                        }

                        let finalDescription = (description?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
                            ? "Key handover submitted"
                            : description!.trimmingCharacters(in: .whitespacesAndNewlines)

                       

                        let result = await viewModel.submitKeyHandoverEvidence(
                            complaintId: complaint.id,
                            unitId: unitId,
                            userId: userId,
                            description: finalDescription,
                            images: images   // ✅ pass photos correctly
                        )

                     
                        // ✅ Close sheet
                        showingPhotoUpload = false
                    }
                },
                onCancel: {
                    showingPhotoUpload = false
                }
            )
        }

        .task {
            await viewModel.loadComplaint(byId: complaintId)
            await viewModel.getProgressLogs(complaintId: complaintId)
//            if let unitId = viewModel.selectedComplaint?.unitId {
//                    await viewModel.loadKeyLogs(unitId: unitId)   // ✅ fetch key logs
//                }
        }
    }

    private func complaintImage(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle().fill(Color.gray.opacity(0.3))
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .cornerRadius(8)
        .clipped()
    }

    private func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
