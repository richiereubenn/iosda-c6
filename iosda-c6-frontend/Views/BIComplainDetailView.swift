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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Judul Komplain")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
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
                            
                            Text("Under Review")
                                .foregroundColor(.black)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.yellow.opacity(0.3))
                                .cornerRadius(12)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Description")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                            
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec sit amet eros id lectus commodo laoreet sed vitae magna...")
                                .foregroundColor(.black)
                                .font(.system(size: 14))
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Image section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Image")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
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
                    }
                    
                    VStack(spacing: 8) {
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
                
                // Location/Unit Detail
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location/Unit Detail")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
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
                .padding(.top, 20)
            }
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Detail Complain")
        
        .alert("Do you want to reject this issue?", isPresented: $showRejectAlert) {
            TextField("Explain why you reject this issue", text: $rejectionReason, axis: .vertical)
            
            Button("Cancel", role: .cancel) {
                rejectionReason = ""
            }
            
            Button("Reject", role: .destructive) {
                // handleReject()
            }
        } message: {
            Text("Explain why you reject this issue")
        }
        
        // Accept sheet - Example with 2 photos
        .sheet(isPresented: $showAcceptSheet) {
            PhotoUploadSheet(
                title: "Start this Work?",
                description: "This will set the work status to\n'In Progress'.",
                photoLabel1: "A close-up photo of the specific defect.",
                photoLabel2: "A wide-angle photo showing the entire work area.",
                uploadAmount: 1, // Change to 1 for single photo upload
                onStartWork: {
                    // handleAccept()
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
