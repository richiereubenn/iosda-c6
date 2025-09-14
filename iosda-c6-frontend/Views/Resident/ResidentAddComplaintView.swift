import SwiftUI
import PhotosUI

struct ResidentAddComplaintView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var unitViewModel: ResidentUnitListViewModel
    @ObservedObject var complaintViewModel: ResidentAddComplaintViewModel
    
    @State private var complaintTitle: String = ""
    @State private var complaintDetails: String = ""
    
    @State private var selectedUnitId: String? = nil
    @State private var navigateToKeyDate = false
    
    @State private var userId: String? = nil
    
    @State private var handoverMethod: HandoverMethod? = nil
    var handoverOptions: [HandoverMethod] = [.bringToMO, .inHouse]
    
    
    @State private var closeUpImage: UIImage? = nil
    @State private var overallImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var currentImageType: ImageType = .closeUp
    enum ImageType {
        case closeUp
        case overall
    }
    
    @State private var isSubmitting: Bool = false
    @State private var showSuccessAlert = false

    var onComplaintSubmitted: (() -> Void)? = nil
    
    
    var classificationId: String
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
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
                        
//                        if isSubmitting {
//                            HStack {
//                                Spacer()
//                                ProgressView("Submitting...")
//                                    .progressViewStyle(CircularProgressViewStyle())
//                                Spacer()
//                            }
//                            .padding(.top)
//                        }
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
                        handoverMethod: handoverMethod ?? .bringToMO,
                        selectedUnitId: selectedUnitId,
                        complaintTitle: complaintTitle,
                        complaintDetails: complaintDetails,
                        classificationId: classificationId,
                        unitViewModel: unitViewModel,
                        complaintViewModel: complaintViewModel,
                        onComplaintSubmitted: {
                            dismiss()
                        }
                    )
                }
                .alert(isPresented: Binding<Bool>(
                    get: { complaintViewModel.errorMessage != nil },
                    set: { newValue in
                        if !newValue {
                            complaintViewModel.errorMessage = nil
                        }
                    }
                )) {
                    Alert(
                        title: Text("Upload Failed"),
                        message: Text(complaintViewModel.errorMessage ?? "Something went wrong."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .alert("Success", isPresented: $showSuccessAlert, actions: {
                            Button("OK") {
                                dismiss()
                                onComplaintSubmitted?()
                            }
                        }, message: {
                            Text("Your complaint was submitted successfully.")
                        })

            }
            .onAppear {
                Task {
                    await unitViewModel.loadUnits()
                    if selectedUnitId == nil {
                        selectedUnitId = unitViewModel.claimedUnits.first?.id
                    }
                }
                userId = NetworkManager.shared.getUserIdFromToken()
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
                options: unitViewModel.claimedUnits.map { $0.name ?? "Unnamed Unit" }
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
                // Close-up photo with PhotosPicker
                VStack(spacing: 8) {
                    PhotosPicker(
                        selection: Binding(
                            get: { complaintViewModel.getPhotoItem(for: .closeUp) },
                            set: { complaintViewModel.setPhotoItem($0, for: .closeUp) }
                        ),
                        matching: .images
                    ) {
                        ResidentPhotoUploadCard(
                            title: "Close-up Photo",
                            image: complaintViewModel.getImage(for: .closeUp),
                            onTap: { /* PhotosPicker handles the tap */ },
                            onRemove: {
                                complaintViewModel.removeImage(for: .closeUp)
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    
                    imageInstructionView(text: "Take a close-up photo focusing on the issue. Ensure the defect is clear and well-lit.")
                }
                
                // Overall photo with PhotosPicker
                VStack(spacing: 8) {
                    PhotosPicker(
                        selection: Binding(
                            get: { complaintViewModel.getPhotoItem(for: .overall) },
                            set: { complaintViewModel.setPhotoItem($0, for: .overall) }
                        ),
                        matching: .images
                    ) {
                        ResidentPhotoUploadCard(
                            title: "Overall Photo",
                            image: complaintViewModel.getImage(for: .overall),
                            onTap: { /* PhotosPicker handles the tap */ },
                            onRemove: {
                                complaintViewModel.removeImage(for: .overall)
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    
                    imageInstructionView(text: "Take a photo from a distance to show the issue in its surrounding area for context.")
                }
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
        ZStack {
            CustomButtonComponent(
                text: isSubmitting ? "Submitting..." : "Submit Complaint",
                isDisabled: !isFormValid || isSubmitting,
                action: {
                    submitInHouseComplaint()
                }
            )
            .opacity(isSubmitting ? 0.5 : 1)
            
            if isSubmitting {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
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
                guard let selected = unitViewModel.claimedUnits.first(where: { $0.id == selectedUnitId }) else { return "" }
                return selected.name ?? ""
            },
            set: { newValue in
                if let selected = unitViewModel.claimedUnits.first(where: { $0.name == newValue }) {
                    selectedUnitId = selected.id
                }
            }
        )
    }
    
    private var imageBinding: Binding<UIImage?> {
        Binding<UIImage?>(
            get: {
                switch currentImageType {
                case .closeUp:
                    return closeUpImage
                case .overall:
                    return overallImage
                }
            },
            set: { newValue in
                switch currentImageType {
                case .closeUp:
                    closeUpImage = newValue
                case .overall:
                    overallImage = newValue
                }
            }
        )
    }
    
    private var isFormValid: Bool {
        !complaintTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        !complaintDetails.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedUnitId != nil &&
        handoverMethod != nil &&
        complaintViewModel.getImage(for: .closeUp) != nil &&
        complaintViewModel.getImage(for: .overall) != nil
    }

    
    // MARK: - Functions
    private func submitInHouseComplaint() {
            guard let userId = userId,
                  let unitId = selectedUnitId,
                  let method = handoverMethod,
                  let selectedUnit = unitViewModel.claimedUnits.first(where: { $0.id == unitId }) else {
                return
            }
            
            isSubmitting = true

            Task {
                do {
                    try await complaintViewModel.submitInHouseComplaint(
                        title: complaintTitle,
                        description: complaintDetails,
                        unitId: unitId,
                        userId: userId,
                        statusId: "661a5a05-730b-4dc3-a924-251a1db7a2d7",
                        classificationId: classificationId,
                        latitude: latitude,
                        longitude: longitude,
                        handoverMethod: method,
                        selectedUnit: selectedUnit
                    )
                    
                    print("✅ Complaint submitted successfully")
                    
                    await MainActor.run {
                        isSubmitting = false
                        showSuccessAlert = true
                    }
                } catch {
                    print("❌ Error submitting in-house complaint: \(error)")
                    await MainActor.run {
                        isSubmitting = false
                        complaintViewModel.errorMessage = error.localizedDescription
                    }
                }
            }
        }
        
}

#Preview {
    ResidentAddComplaintView(
        unitViewModel: ResidentUnitListViewModel(),
        complaintViewModel: ResidentAddComplaintViewModel(),
        classificationId: "classA",
        latitude: 0.0,
        longitude: 0.0
    )
}
