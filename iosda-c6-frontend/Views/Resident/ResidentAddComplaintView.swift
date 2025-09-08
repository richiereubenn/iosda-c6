import SwiftUI

struct ResidentAddComplaintView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var unitViewModel: UnitViewModel
    @ObservedObject var complaintViewModel: ComplaintListViewModel
    
    @State private var complaintTitle: String = ""
    @State private var complaintDetails: String = ""
    @State private var handoverMethod: Complaint.HandoverMethod? = nil
    @State private var selectedUnitId: Int? = nil
    
    @State private var navigateToKeyDate = false
    
    var handoverOptions: [Complaint.HandoverMethod] = [.bringToMO, .inHouse]
    
    var body: some View {
        VStack(spacing: 10) {
            dragIndicator
            
            NavigationStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
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
                unitViewModel.loadUnits()
                if selectedUnitId == nil {
                    selectedUnitId = unitViewModel.claimedUnits.first?.id
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
            .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var titleSection: some View {
        Text("Complaint Title")
            .font(.title2)
            .fontWeight(.bold)
        
        Text("What issues will be included in the report")
            .font(.subheadline)
            .foregroundColor(.gray)
        
        TextField("Enter title", text: $complaintTitle)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    @ViewBuilder
    private var unitSelectionSection: some View {
        Text("Choose House Unit")
            .font(.title2)
            .fontWeight(.bold)
        
        LabeledDropdownPicker(
            label: nil,
            placeholder: "Select House Unit",
            selection: unitBinding,
            options: unitViewModel.claimedUnits.map { $0.name }
        )
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Text("Complaint Details")
            .font(.title2)
            .fontWeight(.bold)
        
        Text("Explain the report in detail")
            .font(.subheadline)
            .foregroundColor(.gray)
        
        TextField("Enter details", text: $complaintDetails, axis: .vertical)
            .lineLimit(5...8)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    @ViewBuilder
    private var imageSection: some View {
        Text("Image")
            .font(.title2)
            .fontWeight(.bold)
        
        Text("Upload images of the problem you are reporting")
            .font(.subheadline)
            .foregroundColor(.gray)
        
        UploadImageCard(imageType: .closeUp)
        imageInstructionView(text: "Please take a close-up photo focusing directly on the issue. Ensure the defect is clear and well-lit to show the full detail.")
        
        UploadImageCard(imageType: .overall)
        imageInstructionView(text: "Please take a photo from a distance to show the issue and its surrounding area. This helps us identify the exact location.")
    }
    
    @ViewBuilder
    private var handoverSection: some View {
        handoverHeader
        
        Text("Select the method to hand over house key for field officers to fix")
            .font(.subheadline)
            .foregroundColor(.gray)
        
        ForEach(handoverOptions, id: \.self) { option in
            HStack {
                Image(systemName: handoverMethod == option ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(.blue)
                    .onTapGesture { handoverMethod = option }
                Text(option.displayName)
                    .onTapGesture { handoverMethod = option }
            }
        }
    }
    
    private var handoverHeader: some View {
        HStack {
            Text("Key Handover Method")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
        }
    }
    
    private var submitButton: some View {
        CustomButtonComponent(
                    text: "Make a Complaint",
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
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .foregroundColor(.gray)
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
        .italic()
    }
    
    // MARK: - Computed Properties
    
    private var unitBinding: Binding<String> {
        Binding<String>(
            get: {
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
        !complaintTitle.isEmpty &&
        !complaintDetails.isEmpty &&
        selectedUnitId != nil &&
        handoverMethod != nil
    }
    
    private func submitInHouseComplaint() {
        guard let unitId = selectedUnitId,
              let method = handoverMethod else { return }
        
        Task {
            do {
                try await complaintViewModel.submitInHouseComplaint(
                    title: complaintTitle,
                    description: complaintDetails,
                    unitId: unitId,
                    handoverMethod: method,
                    unitViewModel: unitViewModel
                )
                dismiss()
            } catch {
                print("Error submitting complaint: \(error)")
                // Optional: Show an alert
            }
        }
    }
}

#Preview {
    ResidentAddComplaintView(unitViewModel: UnitViewModel(),
                             complaintViewModel: ComplaintListViewModel())
}
