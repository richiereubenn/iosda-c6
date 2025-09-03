//
//  BSCComplainDetailView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 31/08/25.
//

import SwiftUI

struct BSCComplainDetailView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @StateObject private var viewModel = BuildingListViewModel()
    @State private var garansiChecked = true
    @State private var izinRenovasiChecked = false
    
    @State private var statusID: Status.ComplaintStatusID = .init(rawValue: 2)!
    
    private var isConfirmDisabled: Bool {
        !(garansiChecked && izinRenovasiChecked)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                if sizeClass == .regular {
                    HStack(spacing: 40) {
                        residenceProfile
                        statusComplain
                    }
                } else {
                    VStack(spacing: 20) {
                        residenceProfile
                        statusComplain
                    }
                }
                
                Text("Complain Description")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if sizeClass == .regular {
                    HStack(alignment: .top, spacing: 20) {
                        complainImages
                        complainDetails
                    }
                } else {
                    VStack(spacing: 20) {
                        complainImages
                        complainDetails
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Syarat")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
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
                
                VStack(alignment: .leading, spacing: 12) {
                    if statusID.rawValue == 3 {
                        HStack(spacing: 16) {
                            CustomButtonComponent(
                                text: "Reject",
                                backgroundColor: .red,
                                textColor: .white,
                                isDisabled: false
                            ) {
                                print("Rejected")
                                statusID = .init(rawValue: 6)!
                            }
                            
                            CustomButtonComponent(
                                text: "Accept",
                                backgroundColor: .green,
                                textColor: .white,
                                isDisabled: isConfirmDisabled
                            ) {
                                print("Accepted")
                                statusID = .init(rawValue: 4)!
                            }
                        }
                    }else if statusID.rawValue == 4 || statusID.rawValue == 6  {
                        
                    }else {
                        CustomButtonComponent(
                            text: "Confirm",
                            backgroundColor: .primaryBlue,
                            textColor: .white,
                            isDisabled: isConfirmDisabled
                        ) {
                            statusID = .init(rawValue: 3)!
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("Detail Complain")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var residenceProfile: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Residence Profile")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 5) {
                DataRowComponent(label: "Nama:", value: "Kevin Mulyono")
                DataRowComponent(label: "Nomor HP:", value: "0858321231231")
                DataRowComponent(label: "Kode Rumah:", value: "AA/ADA/XAV")
                DataRowComponent(label: "Tanggal ST:", value: "20 Januari 2025")
            }
        }
    }
    
    private var statusComplain: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status Complain")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 5) {
                DataRowComponent(label: "Tanggal Masuk:", value: "22 Februari 2025")
                DataRowComponent(label: "Key Status:", value: "In House")
                HStack {
                    Text("Status:")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                    
                    StatusBadge(statusID: statusID)
                    Spacer()
                }
                DataRowComponent(label: "Deadline:", value: "30 Februari 2025")
            }
        }
    }
    
    private var complainImages: some View {
        Group {
            if sizeClass == .regular {
                VStack(spacing: 12) {
                    complaintImage(url: "https://via.placeholder.com/150x100")
                    complaintImage(url: "https://via.placeholder.com/150x100")
                }
            } else {
                HStack(spacing: 12) {
                    complaintImage(url: "https://via.placeholder.com/150x100")
                    complaintImage(url: "https://via.placeholder.com/150x100")
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
    
    private var complainDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            DataRowComponent(label: "Kategori:", value: "Atap")
            DataRowComponent(label: "Detail Kerusakan:", value: "Atap Bocor")
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        BSCComplainDetailView()
    }
}
