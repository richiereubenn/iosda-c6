//
//  BSCComplainDetailView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 31/08/25.
//

import SwiftUI

struct BSCComplainDetailView: View {
    @StateObject private var viewModel = BuildingListViewModel()
    @State private var garansiChecked = true
    @State private var izinRenovasiChecked = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 40){
                    // Residence Profile Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Residence Profile")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 5) {
                            DataRowComponent(label: "Nama:", value: "Kevin Mulyono")
                            DataRowComponent(label: "Nomor HP:", value: "0858321231231")
                            DataRowComponent(label: "Kode Rumah:", value: "AA/ADA/XAV")
                            DataRowComponent(label: "Tanggal ST:", value: "20 Januari 2025")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Status Complain")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 5) {
                            DataRowComponent(label: "Tanggal Masuk:", value: "22 Februari 2025")
                            DataRowComponent(label: "Key Status:", value: "In House")
                            HStack {
                                Text("Status:")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                
                                Text("Open")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(.red)
                                    .cornerRadius(4)
                                Spacer()
                            }
                            DataRowComponent(label: "Deadline:", value: "30 Februari 2025")
                        }
                    }
                    
                }
                
                // Detail Complain Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detail Complain")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack{
                        // Images
                        VStack(spacing: 12) {
                            AsyncImage(url: URL(string: "https://via.placeholder.com/150x100")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 150, height: 100)
                            .cornerRadius(8)
                            .clipped()
                            
                            AsyncImage(url: URL(string: "https://via.placeholder.com/150x100")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 150, height: 100)
                            .cornerRadius(8)
                            .clipped()
                        }
                        
                        VStack{
                            VStack(spacing: 5) {
                                DataRowComponent(label: "Kategori:", value: "Atap")
                                DataRowComponent(label: "Detail Kerusakan:", value: "Atap Bocor")
                                
                            }
                            
                            Spacer()
                                .frame(height: 15)
                            
                            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially uncha")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            
                            
                            
                            Spacer()
                        }
                        
                    }
                    
                    
                }
                
                // Syarat Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Syarat")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 5) {
                        RequirementsCheckbox(
                            text: "Garansi",
                            isChecked: garansiChecked,
                            onToggle: {
                                garansiChecked.toggle()
                            }
                        )
                        
                        RequirementsCheckbox(
                            text: "Izin Renovasi",
                            isChecked: izinRenovasiChecked,
                            onToggle: {
                                izinRenovasiChecked.toggle()
                            }
                        )
                    }
                }
                
                // Decision Section
                VStack(alignment: .leading, spacing: 12) {
                    ComplainDecision(
                        decision: .accept,
                        onTap: {
                            // Handle accept action
                            print("Complain accepted")
                        }
                    )
                }
                
                CustomButtonComponent(text: "Confirm", backgroundColor: .primaryBlue, textColor: .white) {
                }
                
                Spacer(minLength: 20)
            }
        }
        .padding(.horizontal, 20)
        .navigationTitle("Detail Complain")
        .navigationBarTitleDisplayMode(.large)
    }
}
#Preview {
    NavigationStack {
        BSCComplainDetailView()
    }
}
