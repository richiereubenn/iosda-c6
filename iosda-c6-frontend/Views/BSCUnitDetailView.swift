//
//  BSCUnitDetailView.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 02/09/25.
//
import SwiftUI

struct BSCUnitDetailView: View {
    let unit: Unit
    let userUnit: UserUnit?
    @ObservedObject var viewModel: UnitViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    private let dummyUser = (
        name: "John Doe",
        phone: "+62 812-3456-7890",
        email: "john.doe@email.com"
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                if sizeClass == .compact {
                    VStack(spacing: 20) {
                        unitInfoCard
                        userInfoCard
                    }
                } else {
                    HStack(alignment: .top, spacing: 20) {
                        unitInfoCard
                        userInfoCard
                    }
                }
                
                statusRequestCard
                
                Spacer()
                
                if unit.isApproved != true {
                    HStack(spacing: 16) {
                        CustomButtonComponent(
                            text: "Reject",
                            backgroundColor: .red,
                            textColor: .white
                        ) {
                            rejectUnit()
                        }
                        
                        CustomButtonComponent(
                            text: "Accept",
                            backgroundColor: .primaryBlue,
                            textColor: .white
                        ) {
                            acceptUnit()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .navigationTitle("Detail Unit")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
    }
    
    
    private var unitInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informasi Unit")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            GroupedCard{
                VStack(spacing: 5) {
                    DataRowComponent(label: "Nama Unit:", value: unit.name)
                    
                    if let project = unit.project {
                        DataRowComponent(label: "Project:", value: project)
                    }
                    
                    if let area = unit.area {
                        DataRowComponent(label: "Area:", value: area)
                    }
                    
                    if let block = unit.block {
                        DataRowComponent(label: "Block:", value: block)
                    }
                    
                    if let unitNumber = unit.unitNumber {
                        DataRowComponent(label: "No. Unit:", value: unitNumber)
                    }
                    
                    DataRowComponent(
                        label: "Izin Renovasi:",
                        value: unit.renovationPermit! ? "Ya" : "Tidak"
                    )
                    
                    if let ownershipType = userUnit?.ownershipType {
                        DataRowComponent(label: "Tipe Kepemilikan:", value: ownershipType)
                    }
                }
            }
            
        }
    }
    
    private var userInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informasi Pemohon")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            GroupedCard{
                VStack(spacing: 5) {
                    DataRowComponent(label: "Nama:", value: dummyUser.name)
                    DataRowComponent(label: "No. Telepon:", value: dummyUser.phone)
                    DataRowComponent(label: "Email:", value: dummyUser.email)
                }
            }
           
        }
        
    }
    
    private var statusRequestCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status Request")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            GroupedCard{
                HStack {
                    Text("Status:")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                    
                    if unit.isApproved == true {
                        Text("Unit Terdaftar")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(.green)
                            .cornerRadius(4)
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                            
                            Text("Menunggu Persetujuan")
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.orange)
                        .cornerRadius(5)
                    }
                }
            }
            
        }
    }
    
    private func acceptUnit() {
        if let index = viewModel.units.firstIndex(where: { $0.id == unit.id }) {
            viewModel.units[index] = Unit(
                id: unit.id,
                name: unit.name,
                bscUuid: unit.bscUuid,
                biUuid: unit.biUuid,
                contractorUuid: unit.contractorUuid,
                keyUuid: unit.keyUuid,
                project: unit.project,
                area: unit.area,
                block: unit.block,
                unitNumber: unit.unitNumber,
                handoverDate: unit.handoverDate,
                renovationPermit: unit.renovationPermit,
                isApproved: true // Change to approved
            )
        }
        dismiss()
    }
    
    private func rejectUnit() {
        viewModel.deleteUnit(unit)
        dismiss()
    }
}

#Preview {
    let mockUnit = Unit(
        id: "1",
        name: "Northwest Park - NA01/001",
        bscUuid: nil,
        biUuid: nil,
        contractorUuid: nil,
        keyUuid: nil,
        project: "Citraland Surabaya",
        area: "Northwest Park",
        block: "NA",
        unitNumber: "01/001",
        handoverDate: Date(),
        renovationPermit: false,
        isApproved: false
    )
    
    let mockUserUnit = UserUnit(
        id: nil,
        userId: nil,
        unitId: "1",
        ownershipType: "Owner"
    )
    
    NavigationStack {
        BSCUnitDetailView(
            unit: mockUnit,
            userUnit: mockUserUnit,
            viewModel: UnitViewModel()
        )
    }
}
