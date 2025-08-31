//
//  ContentView.swift
//  AddUnit
//
//  Created by Gracia Angelia on 28/08/25.
//

import SwiftUI

struct ResidentAddUnitView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: UnitViewModel
    
    // MARK: - State
    @State private var selectedProject: String = ""
    @State private var selectedArea: String = ""
    @State private var selectedBlock: String = ""
    @State private var selectedUnit: String = ""
    @State private var ownershipStatus: String = ""
    
    // MARK: - Data
    let projects = ["Citraland Surabaya", "Citraland Surabaya (North)"]
    
    let citralandSurabayaAreas = [
        "Alam Hijau", "Bukit Golf", "Bukit Golf International",
        "Bukit Golf Mediterania", "Bukit Telaga Golf", "Buona Vista",
        "CitraLand Central Business District", "CitraLand Fresh Market",
        "Crystal Golf - Mansion Park", "Diamond Hill", "District 9",
        "Eastwood", "Emerald Mansion"
    ]
    
    let citralandNorthAreas = [
        "Northwest Park", "Northwest Lake", "Northwest Hill",
        "Northwest Central", "Pelican Hill",
        "Greenland Residence", "Dempsey Hill"
    ]
    
    // Mapping area → block
    let blockMapping: [String: [String]] = [
        "Northwest Park": ["Block NA", "Block NB", "Block NC", "Block ND"],
        "Northwest Lake": ["Block A", "Block B"],
    ]
    
    // Mapping block → unit
    let unitMapping: [String: [String]] = [
        "Block NA": ["1/1", "1/2", "1/3"],
        "Block NB": ["8/23", "8/24"],
        "Block ND": ["9/33", "9/34"],
        "Block NC": ["7/10", "7/11"]

    ]
    
    let ownershipOptions = ["Owner", "Family", "Others"]
    
    var body: some View {
        VStack(spacing: 20) {
            
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            HStack {
                Text("Add Unit")
                    .font(.headline)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Unit")
                        .font(.headline)
                        .padding(.top, 4)
                    
                    Text("Fill in the information of the unit to be claimed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Project
                    CustomPicker(title: "Select Project", selection: $selectedProject, options: projects)
                    
                    // Area (aktif kalau project != "")
                    CustomPicker(
                        title: "Select Area",
                        selection: $selectedArea,
                        options: areasForSelectedProject
                    )
                    .disabled(selectedProject.isEmpty)
                    .opacity(selectedProject.isEmpty ? 0.5 : 1)
                    
                    // Block (aktif kalau area != "")
                    CustomPicker(
                        title: "Select Block",
                        selection: $selectedBlock,
                        options: blockMapping[selectedArea] ?? []
                    )
                    .disabled(selectedArea.isEmpty)
                    .opacity(selectedArea.isEmpty ? 0.5 : 1)
                    
                    // Unit (aktif kalau block != "")
                    CustomPicker(
                        title: "Select Unit",
                        selection: $selectedUnit,
                        options: unitMapping[selectedBlock] ?? []
                    )
                    .disabled(selectedBlock.isEmpty)
                    .opacity(selectedBlock.isEmpty ? 0.5 : 1)
                    
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
                                    .foregroundColor(.blue)
                                    .onTapGesture { ownershipStatus = option }
                                Text(option)
                                    .onTapGesture { ownershipStatus = option }
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    // Submit
                    Button(action: {
                        viewModel.addUnit(
                        name: selectedProject + " - " + selectedUnit,
                        project: selectedProject,
                        area: selectedArea,
                        block: selectedBlock,
                        unitNumber: selectedUnit,
                        handoverDate: nil,
                        renovationPermit: false,
                        ownershipType: ownershipStatus
                        )
                    }) {
                        Text("Submit a Claim")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isFormValid || viewModel.isLoading)
                    .padding(.top, 12)
                }
                .padding(.horizontal)
            }
        }
        .presentationDetents([.large])
    }
    
    // MARK: - Helper
    private var areasForSelectedProject: [String] {
        if selectedProject == "Citraland Surabaya" {
            return citralandSurabayaAreas
        } else if selectedProject == "Citraland Surabaya (North)" {
            return citralandNorthAreas
        }
        return []
    }
    private var isFormValid: Bool {
            !selectedProject.isEmpty &&
            !selectedArea.isEmpty &&
            !selectedBlock.isEmpty &&
            !selectedUnit.isEmpty &&
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
                    .foregroundColor(selection.isEmpty ? .gray : .black)
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
    ResidentAddUnitView(viewModel: UnitViewModel())
}
