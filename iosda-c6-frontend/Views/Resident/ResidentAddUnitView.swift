//
//  ContentView.swift
//  AddUnit
//
//  Created by Gracia Angelia on 28/08/25.
//

import SwiftUI


struct ResidentAddUnitView: View {
    @Environment(\.dismiss) private var dismiss
    //@ObservedObject var viewModel: UnitViewModel
    @ObservedObject var viewModel: AddUnitViewModel
    //@Environment(\.dismiss) var dismiss
    @State private var showingErrorAlert = false

    //@StateObject var viewModel = AddUnitViewModel()
    let userId: String

    
    // MARK: - State
    @State private var projects: [Project] = []
    @State private var isLoadingProjects: Bool = false
    @State private var projectLoadError: String?

    @State private var allAreas: [Area] = []
    @State private var isLoadingAreas: Bool = false
    @State private var areaLoadError: String?
    private var filteredAreas: [Area] {
        guard let selectedProject = projects.first(where: { $0.name == selectedProjectName }) else {
            return []
        }
        return allAreas.filter { $0.projectId == selectedProject.id }
    }
    
    @State private var allBlocks: [Block] = []
    @State private var isLoadingBlocks: Bool = false
    @State private var blockLoadError: String?
    private var filteredBlocks: [Block] {
        guard let area = filteredAreas.first(where: { $0.name == selectedAreaName }) else {
         
            return []
        }
        let matchingBlocks = allBlocks.filter { $0.areaId == area.id }
        
        return matchingBlocks
    }

    @State private var unitCodes: [UnitCode] = []
    @State private var isLoadingUnitCodes: Bool = false
    @State private var unitCodeLoadError: String?
    private var filteredUnitCodes: [UnitCode] {
        guard let block = filteredBlocks.first(where: { $0.name == selectedBlockName }) else {
         
            return []
        }
        let matchingUnitCode = unitCodes.filter { $0.blockId == block.id }
    
        return matchingUnitCode
    }

    @State private var selectedProjectName: String = ""
    @State private var selectedProjectId: String = ""
    @Binding var selectedAreaName: String
    @State private var selectedAreaId: String = ""
    @State private var selectedBlockName: String = ""
    @State private var selectedBlockId: String = ""
    @Binding var selectedUnitCodeName: String
    @Binding var selectedUnitCodeId: String
    @State private var ownershipStatus: String = ""
    

    
   
    let ownershipOptions = ["Owner", "Family", "Others"]
    
    var body: some View {
        VStack{
//            RoundedRectangle(cornerRadius: 3)
//                .fill(Color.gray.opacity(0.4))
//                .frame(width: 40, height: 5)
//                .padding(.top, 10)
            
        NavigationStack{
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("Unit")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 4)
                        
                        Text("Fill in the information of the unit to be claimed")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if isLoadingProjects {
                            ProgressView("Loading Projects...")
                        } else if let error = projectLoadError {
                            Text(error).foregroundColor(.red)
                        } else {
                            LabeledDropdownPicker(
                                label: "Project",
                                placeholder: "Select Project",
                                selection: $selectedProjectName,
                                options: projects.map { $0.name }
                            )
                            .onChange(of: selectedProjectName) { _, newValue in
                                if let project = projects.first(where: { $0.name == newValue }) {
                                    selectedProjectId = project.id
                                }
                                // Reset area selection when project changes
                                selectedAreaName = ""
                                selectedAreaId = ""
                                
                                // Also reset dependent selections if needed
                                selectedBlockName = ""
                                selectedBlockId = ""
                                selectedUnitCodeName = ""
                                selectedUnitCodeId = ""
                            }
                            
                            
                        }
                        
                        if isLoadingAreas {
                            ProgressView("Loading Areas...")
                        } else if let error = areaLoadError {
                            Text(error).foregroundColor(.red)
                        } else {
                            LabeledDropdownPicker(
                                label: "Area",
                                placeholder: "Select Area",
                                selection: $selectedAreaName,
                                options: filteredAreas.map { $0.name },
                                isDisabled: selectedProjectName.isEmpty
                            )
                            .onChange(of: selectedAreaName) { _, newValue in
                                if let area = allAreas.first(where: { $0.name == newValue }) {
                                    selectedAreaId = area.id
                                    // Reset block and unit code when area changes
                                    selectedBlockName = ""
                                    selectedBlockId = ""
                                    selectedUnitCodeName = ""
                                    selectedUnitCodeId = ""
                                }
                            }
                        }
                        
                        if isLoadingBlocks {
                            ProgressView("Loading Blocks...")
                        } else if let error = blockLoadError {
                            Text(error).foregroundColor(.red)
                        } else {
                            LabeledDropdownPicker(
                                label: "Block",
                                placeholder: "Select Block",
                                selection: $selectedBlockName,
                                options: filteredBlocks.map { $0.name },
                                isDisabled: selectedAreaName.isEmpty
                            )
                            .onChange(of: selectedBlockName) { _, newValue in
                                if let block = filteredBlocks.first(where: { $0.name == newValue }) {
                                    selectedBlockId = block.id
                                    // Reset unit code when block changes
                                    selectedUnitCodeName = ""
                                    selectedUnitCodeId = ""
                                }
                            }
                            
                        }
                        
                        
                        if isLoadingUnitCodes {
                            ProgressView("Loading Unit Codes...")
                        } else if let error = unitCodeLoadError {
                            Text(error).foregroundColor(.red)
                        } else {
                            LabeledDropdownPicker(
                                label: "Unit Code",
                                placeholder: "Select Unit Code",
                                selection: $selectedUnitCodeName,
                                options: filteredUnitCodes.map { $0.name },
                                isDisabled: selectedBlockName.isEmpty
                            )
                            .onChange(of: selectedUnitCodeName) { _, newValue in
                                if let unitCode = filteredUnitCodes.first(where: { $0.name == newValue }) {
                                    selectedUnitCodeId = unitCode.id
                                }
                            }
                        }
                        
                        
                        
                        // Ownership
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unit Ownership Status")
                                .font(.headline)
                            
                            Text("Select the ownership status of the unit to be claimed")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ForEach(ownershipOptions, id: \.self) { option in
                                HStack {
                                    Image(systemName: ownershipStatus == option ? "largecircle.fill.circle" : "circle")
                                        .foregroundColor(.primaryBlue)
                                        .onTapGesture { ownershipStatus = option }
                                    Text(option)
                                        .onTapGesture { ownershipStatus = option }
                                }
                            }
                        }
                        .padding(.top, 8)
                        
                        CustomButtonComponent(
                            text: "Submit a Claim",
                            backgroundColor: .primaryBlue,
                            isDisabled: !isFormValid || viewModel.isLoading
                        ) {
                            // Set userId and other values before submitting
                            viewModel.residentId = userId
                            viewModel.areaName = selectedAreaName
                            viewModel.unitCodeName = selectedUnitCodeName
                            viewModel.unitCodeId = selectedUnitCodeId
                            
                            Task {
                                await viewModel.submitUnitClaim {
                                    dismiss() // ✅ Dismiss sheet on success
                                }
                                
                                // Show alert if there's an error
                                if viewModel.errorMessage != nil {
                                    showingErrorAlert = true
                                }
                            }
                        }
                        .padding(.top)

                    }
                }
                
                .padding(.horizontal)
            
            .navigationTitle("Add Unit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
        }
    }
        .presentationDetents([.large])
        .task {
            await fetchProjects()
            await fetchAreas()
            await fetchBlocks()
            await fetchUnitCodes()
        }
        .onChange(of: viewModel.errorMessage) { newValue, _ in
            if newValue != nil {
                showingErrorAlert = true
            }
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
                dismiss()
            }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }


    }
    
    private func fetchUnitCodes() async {
        isLoadingUnitCodes = true
        do {
            let service = UnitCodeService()
            let fetchedUnitCodes = try await service.getAllUnitCodes()
            DispatchQueue.main.async {
                self.unitCodes = fetchedUnitCodes
            }
        } catch {
            DispatchQueue.main.async {
                self.unitCodeLoadError = "Failed to load unit codes"
            }
        }
        isLoadingUnitCodes = false
    }

    
    private func fetchBlocks() async {
        isLoadingBlocks = true
        do {
            let service = BlockService()
            let fetchedBlocks = try await service.getAllBlocks()
        
            DispatchQueue.main.async {
                self.allBlocks = fetchedBlocks
            }
        } catch {
           
            DispatchQueue.main.async {
                self.blockLoadError = "Failed to load blocks"
            }
        }
        isLoadingBlocks = false
    }


    
    private func fetchAreas() async {
        isLoadingAreas = true
        do {
            let service = AreaService()
            let fetchedAreas = try await service.getAllAreas()
            DispatchQueue.main.async {
                self.allAreas = fetchedAreas
            }
        } catch {
            DispatchQueue.main.async {
                self.areaLoadError = "Failed to load areas"
            }
        }
        isLoadingAreas = false
    }

    private func fetchProjects() async {
        isLoadingProjects = true
        do {
            let service = ProjectService()
            let fetchedProjects = try await service.getAllProjects()
            DispatchQueue.main.async {
                self.projects = fetchedProjects
            }
        } catch {
            DispatchQueue.main.async {
                self.projectLoadError = "Failed to load projects"
            }
        }
        isLoadingProjects = false
    }

    
//    // MARK: - Helper
//    private var areasForSelectedProject: [String] {
//        if selectedProject == "Citraland Surabaya" {
//            return citralandSurabayaAreas
//        } else if selectedProject == "Citraland Surabaya (North)" {
//            return citralandNorthAreas
//        }
//        return []
//    }
    private var isFormValid: Bool {
            !selectedProjectName.isEmpty &&
            !selectedAreaName.isEmpty &&
            !selectedBlockName.isEmpty &&
           !selectedUnitCodeName.isEmpty &&
            !ownershipStatus.isEmpty
        }
}

// MARK: - Custom Picker
struct CustomPicker: View {
    var title: String
    @Binding var selection: String
    var options: [String]
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selection = option
                }
            }
        } label: {
            HStack {
                Text(selection.isEmpty ? title : selection)
                    .foregroundColor(selection.isEmpty ? .gray : .primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
    }
}

#Preview {
    @Previewable @State var selectedAreaName = ""
    @Previewable @State var selectedUnitCodeName = ""
    @Previewable @State var selectedUnitCodeId = ""

    ResidentAddUnitView(
        viewModel: AddUnitViewModel(),
        userId: "2b4fa7fe-0858-4365-859f-56d77ba53764",
        selectedAreaName: $selectedAreaName,
        selectedUnitCodeName: $selectedUnitCodeName,
        selectedUnitCodeId: $selectedUnitCodeId
    )
}

