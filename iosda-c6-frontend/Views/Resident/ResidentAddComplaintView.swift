import SwiftUI

struct ResidentAddComplaintView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var unitViewModel: UnitViewModel
    @ObservedObject var complaintViewModel: ComplaintListViewModel
    
    @State private var complaintTitle: String = ""
    @State private var complaintDetails: String = ""
    @State private var handoverMethod: Complaint.HandoverMethod? = nil
    
    // 1. FIX: Changed selectedUnitId from Int? to String?
    @State private var selectedUnitId: String? = nil
    
    @State private var navigateToKeyDate = false
    
    var handoverOptions: [Complaint.HandoverMethod] = [.bringToMO, .inHouse]
    
    var body: some View {
        VStack(spacing: 10) {
            dragIndicator
            
            NavigationStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        titleSection
                        unitSelectionSection
                        detailsSection
                        imageSection
                        handoverSection
                        submitButton
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationTitle("Add Complaint")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        closeButton
                    }
                }
                .navigationDestination(isPresented: $navigateToKeyDate) {
                    // This view would also need to be updated to accept a String ID
                    ResidentKeyDateView(
                        handoverMethod: handoverMethod?.rawValue ?? "",
                        selectedUnitId: selectedUnitId,
                        complaintTitle: complaintTitle,
                        complaintDetails: complaintDetails,
                        unitViewModel: unitViewModel,
                        complaintViewModel: complaintViewModel,
                        onComplaintSubmitted: {
                            dismiss()
                        }
                    )
                }
            }
            .onAppear {
                Task {
                    await unitViewModel.loadUnits()
                    if selectedUnitId == nil {
                        selectedUnitId = unitViewModel.claimedUnits.first?.id
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.gray.opacity(0.4))
            .frame(width: 40, height: 5)
            .padding(.top, 10)
    }
    
    @ViewBuilder
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Complaint Title")
                .font(.headline)
            Text("Provide a clear and concise title for the issue.")
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField("e.g., Leaking Kitchen Faucet", text: $complaintTitle)
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private var unitSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("House Unit")
                .font(.headline)
            LabeledDropdownPicker(
                label: nil,
                placeholder: "Select House Unit",
                selection: unitBinding,
                options: unitViewModel.claimedUnits.map { $0.name }
            )
        }
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Complaint Details")
                .font(.headline)
            Text("Describe the problem in as much detail as possible.")
                .font(.subheadline)
                .foregroundColor(.gray)
            TextEditor(text: $complaintDetails)
                .frame(height: 150)
                .padding(8)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Attach Images")
                .font(.headline)
            Text("Upload photos to help us understand the issue better.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(spacing: 16) {
                UploadImageCard(imageType: .closeUp)
                imageInstructionView(text: "Take a close-up photo focusing on the issue. Ensure the defect is clear and well-lit.")
                
                UploadImageCard(imageType: .overall)
                imageInstructionView(text: "Take a photo from a distance to show the issue in its surrounding area for context.")
            }
        }
    }
    
    @ViewBuilder
    private var handoverSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Key Handover Method")
                .font(.headline)
            Text("Select how our team can access the unit for repairs.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ForEach(handoverOptions, id: \.self) { option in
                Button(action: { handoverMethod = option }) {
                    HStack {
                        Image(systemName: handoverMethod == option ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(.accentColor)
                        Text(option.displayName)
                        Spacer()
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var submitButton: some View {
        CustomButtonComponent(
            text: "Submit Complaint",
            isDisabled: !isFormValid,
            action: {
                if handoverMethod == .bringToMO {
                    navigateToKeyDate = true
                } else if handoverMethod == .inHouse {
                    submitInHouseComplaint()
                }
            }
        )
        .padding(.top, 12)
    }
    
    private var closeButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundColor(.gray.opacity(0.5))
        }
    }
    
    // MARK: - Helper Views
    
    private func imageInstructionView(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle.fill")
            Text(text)
        }
        .font(.caption)
        .foregroundColor(.gray)
    }
    
    // MARK: - Computed Properties
    
    private var unitBinding: Binding<String> {
        Binding<String>(
            get: {
                // This logic is now correct with String IDs
                guard let selected = unitViewModel.claimedUnits.first(where: { $0.id == selectedUnitId }) else { return "" }
                return selected.name
            },
            set: { newValue in
                if let selected = unitViewModel.claimedUnits.first(where: { $0.name == newValue }) {
                    selectedUnitId = selected.id
                }
            }
        )
    }
    
    private var isFormValid: Bool {
        !complaintTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        !complaintDetails.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedUnitId != nil &&
        handoverMethod != nil
    }
    
    // MARK: - Functions
    private func submitInHouseComplaint() {
        guard let unitId = selectedUnitId,
              let method = handoverMethod,
              let selectedUnit = unitViewModel.claimedUnits.first(where: { $0.id == unitId }) else {
            return
        }

        Task {
            do {
                try await complaintViewModel.submitInHouseComplaint(
                    title: complaintTitle,
                    description: complaintDetails,
                    unitId: unitId,
                    handoverMethod: method,
                    unitViewModel: unitViewModel
                )

                dismiss() // 
            } catch {
                print("Error submitting in-house complaint: \(error)")
                // TODO: Show an error alert to the user
            }
        }
    }

}

#Preview {
    ResidentAddComplaintView(unitViewModel: UnitViewModel(),
                             complaintViewModel: ComplaintListViewModel())
}
