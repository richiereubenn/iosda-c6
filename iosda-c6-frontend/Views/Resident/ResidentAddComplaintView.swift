import SwiftUI
import PhotosUI

struct ResidentAddComplaintView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var unitViewModel: ResidentUnitListViewModel
    @StateObject var complaintViewModel: ResidentAddComplaintViewModel
    @StateObject var complaintListViewModel: ResidentComplaintListViewModel
    
    @State private var complaintTitle: String = ""
    @State private var complaintDetails: String = ""
    
    @State private var selectedUnitId: String? = nil
    @State private var navigateToKeyDate = false
    
    @State private var userId: String? = nil
    
    @State private var handoverMethod: HandoverMethod? = nil
    var handoverOptions: [HandoverMethod] = [.bringToMO, .inHouse]
    @State private var isHandoverMethodLocked = false
    
    @State private var showHandoverConflictAlert = false
    @State private var pendingHandoverMethod: HandoverMethod? = nil

    
    @State private var closeUpImage: UIImage? = nil
    @State private var overallImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var currentImageType: ImageType = .closeUp
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showImageSourceDialog = false
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
            //dragIndicator
            
            NavigationStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        titleSection
                        unitSelectionSection
                        detailsSection
                        imageSection
                        if isHandoverMethodLocked {
                            lockedHandoverSection
                        } else {
                            handoverSection
                        }
                        
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
                        handoverMethod: handoverMethod ?? .bringToMO,
                        selectedUnitId: selectedUnitId,
                        complaintTitle: complaintTitle,
                        complaintDetails: complaintDetails,
                        classificationId: classificationId,
                        unitViewModel: unitViewModel,
                        complaintViewModel: complaintViewModel,
                        complaintListViewModel: complaintListViewModel, // Add this line
                        onComplaintSubmitted: {
                               Task {
                                   if let userId = NetworkManager.shared.getUserIdFromToken() {
                                       await complaintListViewModel.loadComplaints(byUserId: userId) // 👈 refresh with correct user
                                       await MainActor.run {
                                           dismiss() // 👈 close KeyDateView after refresh
                                       }
                                   }
                               }
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
                .alert("Different handover method detected",
                       isPresented: $showHandoverConflictAlert) {
                    Button("Cancel", role: .cancel) {
                     
                    }
                    Button("Proceed") {
                        Task {
                            if let unitId = selectedUnitId,
                               let newMethod = pendingHandoverMethod {
                                await complaintListViewModel.resolveHandoverConflict(
                                    unitId: unitId,
                                    newMethod: newMethod
                                )

                                // 🔥 Don’t reload here
                                isHandoverMethodLocked = complaintListViewModel.isHandoverMethodLocked(for: unitId)
                                handoverMethod = newMethod
                            }
                        }
                    }
                } message: {
                    Text("There are complaints under review by BSC with a different handover method. Do you want to update them and reset the unit's key handover date?")
                }
                .onAppear {
                    Task {
                        await unitViewModel.loadUnits()
                        if selectedUnitId == nil {
                            selectedUnitId = unitViewModel.selectedUnit?.id

                        }
                        if let unitId = selectedUnitId {
                            await complaintListViewModel.loadComplaints(byUnitId: unitId)
                            isHandoverMethodLocked = complaintListViewModel.isHandoverMethodLocked(for: unitId)
                            if isHandoverMethodLocked {
                                handoverMethod = nil
                            }
                        }
                        userId = NetworkManager.shared.getUserIdFromToken()
                    }
                }
                .onChange(of: selectedUnitId) { newUnitId in
                    guard let unitId = newUnitId else { return }
                    Task {
                        await complaintListViewModel.loadComplaints(byUnitId: unitId)
                        isHandoverMethodLocked = complaintListViewModel.isHandoverMethodLocked(for: unitId)
                        if isHandoverMethodLocked {
                            handoverMethod = nil
                        }
                    }
                }
            }
            .confirmationDialog("Choose Image Source", isPresented: $showImageSourceDialog) {
                Button("Camera") {
                    imageSource = .camera
                    showImagePicker = true
                }
                Button("Photo Library") {
                    imageSource = .photoLibrary
                    showImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: imageSource) { image in
                    switch currentImageType {
                    case .closeUp:
                        complaintViewModel.closeUpImage = image
                    case .overall:
                        complaintViewModel.overallImage = image
                    }
                }
            }

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
                selection: unitNameBinding,
                options: unitViewModel.claimedUnits.map { $0.name ?? "Unnamed Unit" }
            )
        }
    }
    private var unitNameBinding: Binding<String> {
        Binding<String>(
            get: {
                // Convert selectedUnitId -> unit name
                guard let selectedId = selectedUnitId,
                      let unit = unitViewModel.claimedUnits.first(where: { $0.id == selectedId }) else {
                    return ""
                }
                return unit.name ?? ""
            },
            set: { newName in
                // Convert selected name -> selectedUnitId
                if let selected = unitViewModel.claimedUnits.first(where: { $0.name == newName }) {
                    selectedUnitId = selected.id
                } else {
                    selectedUnitId = nil
                }
            }
        )
    }
    
    
    // MARK: - View Components
    
//    private var dragIndicator: some View {
//        RoundedRectangle(cornerRadius: 3)
//            .fill(Color.gray.opacity(0.4))
//            .frame(width: 40, height: 5)
//            .padding(.top, 10)
//    }
    
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
                // Close-up photo
                VStack(spacing: 8) {
                    Button {
                        currentImageType = .closeUp
                        showImageSourceDialog = true
                    } label: {
                        ResidentPhotoUploadCard(
                            title: "Close-up Photo",
                            image: complaintViewModel.getImage(for: .closeUp),
                            onTap: {},
                            onRemove: {
                                complaintViewModel.removeImage(for: .closeUp)
                            }
                        )
                    }
                    .buttonStyle(.plain)

                    imageInstructionView(text: "Take a close-up photo focusing on the issue. Ensure the defect is clear and well-lit.")
                }

                // Overall photo
                VStack(spacing: 8) {
                    Button {
                        currentImageType = .overall
                        showImageSourceDialog = true
                    } label: {
                        ResidentPhotoUploadCard(
                            title: "Overall Photo",
                            image: complaintViewModel.getImage(for: .overall),
                            onTap: {},
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
                Button(action: {
                    if let unitId = selectedUnitId {
                        // Check for conflict
                        let hasConflict = complaintListViewModel.complaints.contains {
                            $0.unitId == unitId &&
                            $0.statusName?.lowercased() == "under review by bsc" &&
                            $0.handoverMethod != option
                        }
                        
                        if hasConflict {
                            pendingHandoverMethod = option
                            showHandoverConflictAlert = true
                        } else {
                            handoverMethod = option
                        }
                    } else {
                        handoverMethod = option
                    }
                }) {
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
                backgroundColor: .primaryBlue,
                isDisabled: !isFormValid || isSubmitting,
                action: {
                    guard let selectedUnit = unitViewModel.selectedUnit else { return }
                    
                    Task {
                        let methodToCheck = handoverMethod ?? .inHouse
                        let hasConflict = await checkForHandoverConflicts(
                            unitId: selectedUnit.id,
                            newMethod: methodToCheck
                        )
                        
                        if hasConflict {
                            pendingHandoverMethod = methodToCheck
                            
                            showHandoverConflictAlert = true
                        } else {
                            if handoverMethod == .bringToMO {
                                navigateToKeyDate = true
                            } else {
                                await submitInHouseComplaint()
                            }
                        }
                    }
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
    
    private var lockedHandoverText: String {
        guard let unitId = selectedUnitId else {
           
            return HandoverMethod.handoverLocked.displayName
            
        }
        
      
        
        // Debug: Print all complaints for this unit
        let unitComplaints = complaintListViewModel.complaints.filter { $0.unitId == unitId }
       
        for complaint in unitComplaints {
            let status = ComplaintStatus(raw: complaint.statusName)
            print("   - Status: \(complaint.statusName) -> \(status.displayName), isLocking: \(status.isLockingStatus)")
        }
        
        guard !complaintListViewModel.complaints.isEmpty,
              let activeComplaint = complaintListViewModel.complaints.first(where: {
                  $0.unitId == unitId &&
                  ComplaintStatus(raw: $0.statusName).isLockingStatus
              }) else {
         
            return HandoverMethod.handoverLocked.displayName
        }
        
     
        return ComplaintStatus(raw: activeComplaint.statusName).displayName
    }
    
    
    
    private var lockedHandoverSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Key Handover Method")
                .font(.headline)
            Text("This handover method is locked because another complaint for this unit is already in progress.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.accentColor)
                //Text(lockedHandoverText) // 👈 Dynamic display based on status
                Text("Another complaint is in progress")
                    .fontWeight(.medium)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(8)
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
        complaintViewModel.getImage(for: .closeUp) != nil &&
        complaintViewModel.getImage(for: .overall) != nil &&
        (isHandoverMethodLocked || handoverMethod != nil)
    }
    
    
    
    
    // MARK: - Functions
    private func submitInHouseComplaint() {
        guard let userId = userId,
              let unitId = selectedUnitId,
              let selectedUnit = unitViewModel.claimedUnits.first(where: { $0.id == unitId }) else {
            return
        }
        
        let methodToSend: HandoverMethod
        if handoverMethod == .handoverLocked {
            methodToSend = .bringToMO // 👈 fallback if locked
        } else {
            methodToSend = handoverMethod ?? .bringToMO // 👈 unwrap safely
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
                    //classificationId: classificationId,
                    latitude: latitude,
                    longitude: longitude,
                    handoverMethod: methodToSend,
                    selectedUnit: selectedUnit
                )
                
                
              
                if let unitId = selectedUnitId {
                    do {
                        await complaintListViewModel.loadComplaints(byUnitId: unitId)
                    } catch {
                     
                    }
                }
                
                await MainActor.run {
                    isSubmitting = false
                    showSuccessAlert = true
                }
            } catch {
                
                await MainActor.run {
                    isSubmitting = false
                    complaintViewModel.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func isHandoverMethodLocked(for unitId: String) -> Bool {
        return complaintListViewModel.complaints.contains {
            $0.unitId == unitId &&
            ComplaintStatus(raw: $0.statusName).isLockingStatus
        }
    }
    private func checkForHandoverConflicts(unitId: String, newMethod: HandoverMethod) async -> Bool {
        // Refresh complaints data first
        await complaintListViewModel.loadComplaints(byUnitId: unitId)
        
        return complaintListViewModel.complaints.contains {
            $0.unitId == unitId &&
            $0.statusName?.lowercased() == "under review by bsc" &&
            $0.handoverMethod != newMethod
        }
    }
    
    
    
    
}

#Preview {
    ResidentAddComplaintView(
        unitViewModel: ResidentUnitListViewModel(),
        complaintViewModel: ResidentAddComplaintViewModel(),
        complaintListViewModel: ResidentComplaintListViewModel(),
        classificationId: "classA",
        latitude: 0.0,
        longitude: 0.0
    )
}
