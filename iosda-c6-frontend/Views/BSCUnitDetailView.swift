import SwiftUI

struct BSCUnitDetailView: View {
    let unitId: String
    @ObservedObject var viewModel: BSCUnitListViewModel
    @StateObject private var detailVM = BSCUnitDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    @State private var showSuccessAlert = false
    @State private var successMessage = "Unit berhasil dikonfirmasi!"
    
    var body: some View {
            ZStack {
                // 🔹 Background abu-abu full screen
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        if detailVM.isLoading {
                            ProgressView("Loading unit...")
                        } else {
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
                            
                            if detailVM.unit?.bscId == nil {
                                HStack(spacing: 16) {
                                    CustomButtonComponent(
                                        text: "Accept",
                                        backgroundColor: .primaryBlue,
                                        textColor: .white
                                    ) {
                                        Task {
                                            if let unit = detailVM.unit {
                                                await detailVM.confirmUnit(unitId: unit.id)
                                                viewModel.acceptUnit(unit)
                                                // ✅ Tampilkan alert
                                                successMessage = "Unit \(unit.unitNumber ?? "") berhasil dikonfirmasi!"
                                                showSuccessAlert = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Detail Unit")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await detailVM.loadUnit(unitId: unitId)
            }
            .alert("Progress Updated", isPresented: $showSuccessAlert, actions: {
                Button("OK", role: .cancel) {
                    showSuccessAlert = false
                }
            }, message: {
                Text(successMessage)
            })
        }
    
    private var unitInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informasi Unit")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            GroupedCard {
                VStack(spacing: 5) {
                    DataRowComponent(label: "Nama Unit:", value: detailVM.unitName)
                    DataRowComponent(label: "Project:", value: detailVM.projectName)
                    DataRowComponent(label: "Area:", value: detailVM.areaName)
                    DataRowComponent(label: "Block:", value: detailVM.blockName)
                    DataRowComponent(label: "No. Unit:", value: detailVM.unit?.unitNumber ?? "-")
                    DataRowComponent(label: "Izin Renovasi:", value: (detailVM.unit?.renovationPermit ?? false) ? "Ya" : "Tidak")
                }
            }
        }
    }
    
    private var userInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informasi Pemohon")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            GroupedCard {
                VStack(spacing: 5) {
                    DataRowComponent(label: "Nama:", value: detailVM.resident?.name ?? "-")
                    DataRowComponent(label: "No. Telepon:", value: detailVM.resident?.phone ?? "-")
                    DataRowComponent(label: "Email:", value: detailVM.resident?.email ?? "-")
                }
            }
        }
    }
    
    private var statusRequestCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status Request")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            GroupedCard {
                HStack {
                    Text("Status:")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                    
                    if detailVM.unit?.bscId != nil {
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
}
