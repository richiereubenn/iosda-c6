//
//  BSCComplainList.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 03/09/25.
//

import SwiftUI

struct BSCComplaintListView: View {
    let unitId : String
    let userId : String = "60d177e9-c2dc-46eb-8dd8-ba51091dc87a" 
    @StateObject var viewModel = ComplaintListViewModel2()
    
    var body: some View {
        ZStack {
            VStack {
                Button {
                    Task {
                        await viewModel.handleButtonTap(unitId: unitId, userId: userId)
                    }
                } label: {
                    Text(viewModel.buttonTitle)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isButtonEnabled ? Color.primaryBlue : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!viewModel.isButtonEnabled)
                .padding()
                
                Picker("Complaint Status", selection: $viewModel.selectedFilter) {
                    ForEach(ComplaintListViewModel2.ComplaintFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                    Spacer()
                } else if viewModel.filteredComplaints.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Text("No complaints found")
                            .font(.body.weight(.medium))
                            .foregroundColor(.secondary)
                            .minimumScaleFactor(0.8)
                            .lineLimit(2)
                    }
                    .padding(.top, 40)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.filteredComplaints) { complaint in
                                NavigationLink(destination: BSCComplainDetailView(complaintId: complaint.id)) {
                                    ComplaintCard(complaint: complaint)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search complaints...")
            .navigationTitle("Kode Rumah")
            .task {
                await viewModel.loadComplaints(byUnitId: unitId)
                await viewModel.evaluateButton(unitId: unitId)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .background(Color(.systemGroupedBackground))
            
            if viewModel.showKeyLogAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.showKeyLogAlert = false }
                
                VStack(spacing: 0) {
                    Text("Key Handover Evidence")
                        .font(.headline)
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        .multilineTextAlignment(.center)
                    
                    if let fileUrl = viewModel.lastKeyLog?.files.first?.url {
                        AsyncImage(url: URL(string: "https://api.kevinchr.com/property/\(fileUrl)")) { image in
                            image.resizable()
                                 .scaledToFit()
                                 .frame(width: 200, height: 200)
                        } placeholder: {
                            ProgressView()
                        }
                        .padding(.vertical, 16)
                    } else {
                        Image(systemName: "key.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .foregroundColor(.primaryBlue)
                            .padding(.vertical, 16)
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.separator))
                    
                    HStack(spacing: 0) {
                        Button {
                            viewModel.rejectKey()
                        } label: {
                            Text("Reject")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        Rectangle()
                            .frame(width: 1, height: 44)
                            .foregroundColor(Color(.separator))
                        
                        Button {
                            Task {
                                await viewModel.acceptKey(unitId: unitId, userId: userId)
                                viewModel.showKeyLogAlert = false
                            }
                        } label: {
                            Text("Accept")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(height: 44)
                }
                .frame(width: 270)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(radius: 20)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showSystemAlert) {
            Button("Reject", role: .cancel) {}
            Button("Accept") {
                Task {
                    await viewModel.acceptKey(unitId: unitId, userId: userId)
                }
            }
        } message: {
            Text("Do you want to accept the key handover?")
        }
        .animation(.easeInOut, value: viewModel.showKeyLogAlert)
    }
}




#Preview {
    Group {
        NavigationStack {
            BSCComplaintListView(unitId: "da34c1d1-0709-4f0d-96f5-2ede46f68e8b")
        }
        .environment(\.sizeCategory, .medium)
        
    }
}

