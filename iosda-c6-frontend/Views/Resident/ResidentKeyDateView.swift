import SwiftUI

struct ResidentKeyDateView: View {
    var handoverMethod: HandoverMethod
    var selectedUnitId: String?
    var complaintTitle: String
    var complaintDetails: String
    @State private var userId: String? = nil
    

    var classificationId: String
    var latitude: Double? = nil
    var longitude: Double? = nil

    
//    @ObservedObject var unitViewModel: UnitViewModel
    @ObservedObject var unitViewModel: ResidentUnitListViewModel

//    @ObservedObject var complaintViewModel: ComplaintListViewModel
    @ObservedObject var complaintViewModel: ResidentAddComplaintViewModel

    
    var onComplaintSubmitted: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var additionalNotes: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showingSuccessAlert = false
    
    private let dayAfterTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
    
    init(
        handoverMethod: HandoverMethod,
        selectedUnitId: String?,
        complaintTitle: String,
        complaintDetails: String,
        classificationId: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        unitViewModel: ResidentUnitListViewModel,
        complaintViewModel: ResidentAddComplaintViewModel,
        onComplaintSubmitted: @escaping () -> Void
    ) {
        self.handoverMethod = handoverMethod
        self.selectedUnitId = selectedUnitId
        self.complaintTitle = complaintTitle
        self.complaintDetails = complaintDetails
        self.classificationId = classificationId
        self.latitude = latitude
        self.longitude = longitude
        self.unitViewModel = unitViewModel
        self.complaintViewModel = complaintViewModel
        self.onComplaintSubmitted = onComplaintSubmitted
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                headerSection
                methodSection
                datePickerSection
                notesSection
                submitButton
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            userId = NetworkManager.shared.getUserIdFromToken()
        }
        .navigationTitle("Key Handover")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Complaint Submitted", isPresented: $showingSuccessAlert) {
            Button("OK") {
                onComplaintSubmitted() // Dismisses both views
            }

        } message: {
            Text("Your complaint has been submitted successfully!")
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var headerSection: some View {
        Text("Schedule for Key Handover for Repairs")
            .font(.title2)
            .fontWeight(.bold)

        Text("In order for us to immediately process repairs to your unit, please let us know when you are available to hand over the keys to our team.")
            .font(.subheadline)
            .foregroundColor(.gray)
    }
    
    @ViewBuilder
    private var methodSection: some View {
        HStack {
            Text("Selected Method:")
                .font(.headline)
            Text(handoverMethod.displayName)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .cornerRadius(6)
        }
    }
    
    @ViewBuilder
    private var datePickerSection: some View {
        DatePicker(
            "Please select a date",
            selection: $selectedDate,
            in: dayAfterTomorrow...,
            displayedComponents: [.date]
        )
        .datePickerStyle(GraphicalDatePickerStyle())
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private var notesSection: some View {
        Text("Additional Notes (Optional)")
        
        TextField("e.g. The key is entrusted to the housekeeper, or please call this number.", text: $additionalNotes, axis: .vertical)
            .lineLimit(2...8)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    private var submitButton: some View {
        CustomButtonComponent(
                    text: "Make a Complaint",
                    isDisabled: complaintViewModel.isLoading || !isFormValid,
                    action: submitComplaint
                )
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        selectedDate >= Calendar.current.startOfDay(for: Date())
    }
    
    // MARK: - Methods
    
    private func submitComplaint() {
        guard let unitId = selectedUnitId else {
            print("Error: unitId is nil")
            return
        }

        guard let userId = userId else {
            print("Error: userId is nil")
            return
        }

        // Ensure the selectedUnit is found
        guard var selectedUnit = unitViewModel.claimedUnits.first(where: { $0.id == unitId }) else {
            print("Error: Could not find the selected unit.")
            return
        }

        print("🗓️ === DATE DEBUG INFO ===")
            print("🗓️ selectedDate from picker: \(selectedDate)")
            print("🗓️ selectedDate ISO8601: \(selectedDate.ISO8601Format())")
            print("🗓️ Current Date(): \(Date())")
            print("🗓️ Current Date() ISO8601: \(Date().ISO8601Format())")
            print("🗓️ selectedUnit.keyHandoverDate BEFORE update: \(selectedUnit.keyHandoverDate?.ISO8601Format() ?? "nil")")
            
        // 🔧 FIX: Update the selectedUnit with the picker values BEFORE passing to ViewModel
        selectedUnit.keyHandoverDate = selectedDate
        selectedUnit.keyHandoverNote = additionalNotes.isEmpty ? nil : additionalNotes

        print("🗓️ selectedUnit.keyHandoverDate AFTER update: \(selectedUnit.keyHandoverDate?.ISO8601Format() ?? "nil")")
           print("📝 selectedUnit.keyHandoverNote: \(selectedUnit.keyHandoverNote ?? "nil")")
           print("🗓️ === END DEBUG INFO ===")

        let fixedStatusId = "661a5a05-730b-4dc3-a924-251a1db7a2d7"

        // 🔧 FIX: Remove keyHandoverDate and keyHandoverNote from request since they're handled by the unit
        let request = CreateComplaintRequest2(
            unitId: unitId,
            userId: userId,
            statusId: fixedStatusId,
            classificationId: classificationId,
            title: complaintTitle,
            description: complaintDetails + "\n\nAdditional Notes:\n\(additionalNotes)",
            latitude: latitude,
            longitude: longitude,
            handoverMethod: handoverMethod,
            keyHandoverDate: nil,  // ✅ Let the selectedUnit handle this
            keyHandoverNote: nil   // ✅ Let the selectedUnit handle this
        )

        Task {
            do {
                // Now the selectedUnit has the correct date and note
                await complaintViewModel.submitComplaint(request: request, selectedUnit: selectedUnit)
                await MainActor.run {
                    showingSuccessAlert = true
                }
            } catch {
                print("Failed to submit complaint: \(error)")
            }
        }
    }
    
}



#Preview {
    ResidentKeyDateView(
        handoverMethod: .bringToMO,
        selectedUnitId: "1",
        complaintTitle: "Leaky Faucet",
        complaintDetails: "Water leaking from kitchen faucet.",
        classificationId: "class1",
        unitViewModel: ResidentUnitListViewModel(),
        complaintViewModel: ResidentAddComplaintViewModel(),
        onComplaintSubmitted: { print("Complaint submitted callback") }
    )
}

