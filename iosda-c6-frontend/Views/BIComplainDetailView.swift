//
//  BIComplainDetailView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

struct BIComplaintDetailView: View {
    @State private var showRejectAlert = false
    @State private var showAcceptSheet = false
    @State private var rejectionReason = ""
    
    @State private var statusID: Status.ComplaintStatusID = .init(rawValue: "4")!
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Judul Komplain")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    GroupedCard{
                        VStack(alignment: .leading, spacing: 8) {
                            DataRowComponent(
                                label: "Opened :",
                                value: "25 August 2025 | 13:14:23"
                            )
                            
                            DataRowComponent(
                                label: "Deadline :",
                                value: "01 September 2025 | 13:14:23"
                            )
                            
                            HStack {
                                Text("Status :")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                
//                                StatusBadge(statusID: statusID)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Description")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sit amet eros id lectus commodo laoreet sed vitae magna...")
                                    .foregroundColor(.primary)
                                    .font(.system(size: 14))
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                }
                
               
                VStack(alignment: .leading, spacing: 12) {
                    Text("Image")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    GroupedCard{
                        VStack(spacing: 8) {
                            Text("Close-up view:")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Close-up of the Defect")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        
                            Text("Overall view:")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Overall View of the Area")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location/Unit Detail")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    GroupedCard{
                        VStack(alignment: .leading, spacing: 8) {
                            DataRowComponent(
                                label: "Project :",
                                value: "CitraLand Surabaya"
                            )
                            
                            DataRowComponent(
                                label: "Area :",
                                value: "Bukit Golf"
                            )
                            
                            DataRowComponent(
                                label: "Block :",
                                value: "A03"
                            )
                            
                            DataRowComponent(
                                label: "Unit :",
                                value: "A03/006"
                            )
                            
                            DataRowComponent(
                                label: "Coordinates :",
                                value: "40.7127281, -74.0060152"
                            )
                        }
                    }
                    
                }
                
            }
            .padding(20)
            
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
            .padding(20)

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
                statusID = .init(rawValue: "6")!
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
                uploadAmount: 1,
                onStartWork: {
                    statusID = .init(rawValue: "5")!
                    showAcceptSheet = false
                },
                onCancel: {
                    showAcceptSheet = false
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationView {
        BIComplaintDetailView()
    }
}
