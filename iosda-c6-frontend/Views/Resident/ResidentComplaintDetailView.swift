//import SwiftUI
//struct ResidentComplaintDetailView: View {
//    
//    let complaint: Complaint2
//    @StateObject private var viewModel: ResidentComplaintDetailViewModel
//    
//    // Custom initializer for preview
//    init(complaint: Complaint2, firstProgressFiles: [ProgressFile2] = []) {
//        self.complaint = complaint
//        _viewModel = StateObject(wrappedValue: ResidentComplaintDetailViewModel())
//        // Directly set the files inside the viewModel after creation:
////        _viewModel.wrappedValue.firstProgressFiles = firstProgressFiles
//    }
//    
//    @Environment(\.dismiss) var dismiss
//    @State private var showingProgressDetail = false
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // MARK: - Header
//                VStack(alignment: .leading, spacing: 8) {
//                    Text(complaint.title)
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .multilineTextAlignment(.leading)
//                    
//                    if complaint.handoverMethod == "bring_to_mo" {
//                        if let handoverDate = complaint.keyHandoverDate {
//                            HStack(spacing: 6) {
//                                Text("Key Handover Date:")
//                                    .font(.body)
//                                    .foregroundColor(.secondary)
//                                
//                                Text(formatDate(handoverDate))
//                                    .font(.caption)
//                                    .foregroundColor(.primary)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 4)
//                                    .background(Color(.systemGray5))
//                                    .cornerRadius(6)
//                            }
//                        }
//                    }
//                }
//                .padding(.horizontal, 20)
//                
//                // MARK: - Status Section
//                VStack(alignment: .leading, spacing: 15) {
//                    HStack(spacing: 12) {
//                        Text("Status")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                        
//                        StatusBadge(status: complaint.residentStatus)
//                        
//                        Spacer()
//                        
//                        Button("See Detail") {
//                            showingProgressDetail = true
//                        }
//                        .foregroundColor(.blue)
//                    }
//                    
//                    StatusProgressBar(currentStatusName: complaint.statusName)
//                }
//                .padding(.horizontal, 20)
//                
//                // Info about house visit if in_house method
//                if complaint.handoverMethod == "in_house" {
//                    if let openDate = complaint.openTimestamp {
//                        let estimatedVisitDate = Calendar.current.date(byAdding: .day, value: 3, to: openDate)!
//                        
//                        HStack(alignment: .top, spacing: 8) {
//                            Image(systemName: "info.circle.fill")
//                                .foregroundColor(.blue)
//                            
//                            Text("BSC will come to your house soon, no later than ")
//                                .foregroundColor(.primary)
//                            +
//                            Text(formatDate(estimatedVisitDate))
//                                .bold()
//                        }
//                        .font(.subheadline)
//                        .padding()
//                        .background(Color(.systemGray6))
//                        .cornerRadius(8)
//                        .padding(.horizontal, 20)
//                    }
//                }
//                
//                // MARK: - Detail Section wrapped in GroupedCard
//                Text("Detail")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                GroupedCard {
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                        
//                        VStack(alignment: .leading, spacing: 8) {
//                            DetailRow(label: "ID", value: "#\(complaint.id)")
//                            DetailRow(label: "Complain Type", value: complaint.classificationName ?? "Unknown")
//                            DetailRow(label: "Created", value: formatDateWithTime(complaint.openTimestamp ?? Date()))
//                            
//                            if let unitId = complaint.unitId {
//                                DetailRow(label: "Unit ID", value: unitId)
//                            }
//                            
//                            if let closeTimestamp = complaint.closeTimestamp {
//                                DetailRow(label: "Closed", value: formatDateWithTime(closeTimestamp))
//                            }
//                        }
//                        
//                        if !complaint.description.isEmpty {
//                            Text(complaint.description)
//                                .font(.body)
//                                .foregroundColor(.primary)
//                                .padding(.top, 8)
//                        }
//                        
//                    }
//                }
//                
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Image")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                    
//                    GroupedCard {
//                        VStack(spacing: 8) {
//                            Text("Close-up view:")
//                                .foregroundColor(.gray)
//                                .font(.system(size: 14))
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            
//                            complaintImage(url: "tes")
//                            
//                            Text("Overall view:")
//                                .foregroundColor(.gray)
//                                .font(.system(size: 14))
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            
//                            complaintImage(url: "tes")
//                        }
//                    }
//                }
//            }
//            .padding(.horizontal, 20)
//            Spacer(minLength: 100)
//        }
//        .navigationTitle("")
//        .navigationBarBackButtonHidden(true)
//        .navigationDestination(isPresented: $showingProgressDetail) {
//            ResidentProgressDetailView(complaintId: complaint.id)
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: { dismiss() }) {
//                    HStack(spacing: 5) {
//                        Image(systemName: "chevron.left")
//                        Text("Back")
//                    }
//                    .foregroundColor(.blue)
//                }
//            }
//        }
//        
//        .overlay(alignment: .bottom) {
//            if let status = complaint.statusName?.lowercased(),
//               let method = complaint.handoverMethod,
//               (status == "in progress" || status == "waiting key") && method == "bring_to_mo" {
//                VStack(spacing: 0) {
//                    CustomButtonComponent(
//                        text: "Submit Key Handover Evidence",
//                        action: { /* Handle submit key handover evidence */ }
//                    )
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 20)
//                    .background(Color(.systemBackground))
//                }
//            }
//        }
//        
//    }
//}
//
//private func formatDate(_ date: Date) -> String {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .long
//    return formatter.string(from: date)
//}
//
//private func formatDateWithTime(_ date: Date) -> String {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "d MMM yyyy; HH:mm"
//    return formatter.string(from: date)
//}
//
//// MARK: - Updated Image Component with Better Error Handling
//private func complaintImage(url: String?) -> some View {
//    if let urlString = url, let imageURL = URL(string: urlString) {
//        return AnyView(
//            AsyncImage(url: imageURL) { phase in
//                switch phase {
//                case .empty:
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.3))
//                case .success(let image):
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                case .failure(_):
//                    VStack {
//                        Image(systemName: "exclamationmark.triangle.fill")
//                            .font(.system(size: 40))
//                            .foregroundColor(.orange)
//                        Text("Failed to load image")
//                            .font(.system(size: 14, weight: .medium))
//                            .foregroundColor(.gray)
//                    }
//                @unknown default:
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.3))
//                }
//            }
//            .frame(height: 150)
//            .frame(maxWidth: .infinity)
//            .cornerRadius(8)
//            .clipped()
//        )
//    } else {
//        return AnyView(
//            VStack {
//                Image(systemName: "camera.fill")
//                    .font(.system(size: 40))
//                    .foregroundColor(.gray)
//                Text("No Image Available")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.black)
//            }
//            .frame(height: 150)
//            .frame(maxWidth: .infinity)
//            .background(Color.gray.opacity(0.1))
//            .cornerRadius(8)
//        )
//    }
//}
//
//
//// DetailRow remains the same, reusable component
//struct DetailRow: View {
//    let label: String
//    let value: String
//    
//    var body: some View {
//        HStack {
//            Text("\(label):")
//                .font(.body)
//                .foregroundColor(.secondary)
//            Text(value)
//                .font(.body)
//                .foregroundColor(.primary)
//            Spacer()
//        }
//    }
//}
//
//#Preview {
//    NavigationStack {
//        ResidentComplaintDetailView(
//            complaint: Complaint2(
//                id: "2b4c59bd-0460-426b-a720-80ccd85ed5b2",
//                unitId: "u-12345",
//                userId: "user-67890",
//                statusId: "s-4",
//                classificationId: "c-1",
//                title: "Leaking Faucet in Kitchen",
//                description: "The main kitchen faucet has been dripping constantly for the past two days, wasting water.",
//                openTimestamp: Date(),
//                closeTimestamp: nil,
//                keyHandoverDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
//                deadlineDate: Date(),
//                latitude: nil,
//                longitude: nil,
//                handoverMethod: "in_house",
//                workDetail: nil,
//                workDuration: nil,
//                createdAt: Date(),
//                updatedAt: Date(),
//                statusName: "In Progress",
//                classificationName: "Plumbing"
//            ),
//            firstProgressFiles: [
//                ProgressFile2(id: "1", name: "sample1.jpg", path: nil, url: "https://picsum.photos/200/150", mimeType: "image/jpeg"),
//                ProgressFile2(id: "2", name: "sample2.jpg", path: nil, url: "https://picsum.photos/200/151", mimeType: "image/jpeg"),
//                ProgressFile2(id: "3", name: "sample3.jpg", path: nil, url: "https://picsum.photos/200/152", mimeType: "image/jpeg")
//            ]
//        )
//    }
//}
