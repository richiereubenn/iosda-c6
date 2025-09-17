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

    @ObservedObject var unitViewModel: ResidentUnitListViewModel
    @ObservedObject var complaintViewModel: ResidentAddComplaintViewModel
    @ObservedObject var complaintListViewModel: ResidentComplaintListViewModel
    
    var onComplaintSubmitted: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var additionalNotes: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showingSuccessAlert = false
    
    private let dayAfterTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
    
    @State private var showKeyDateConflictAlert = false
    @State private var pendingKeyDate: Date? = nil
    @State private var existingKeyDate: Date? = nil
    
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
        complaintListViewModel: ResidentComplaintListViewModel,
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
        self.complaintListViewModel = complaintListViewModel
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
        .alert("Different key handover date detected",
               isPresented: $showKeyDateConflictAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Update Date") {
                Task {
                    if let unitId = selectedUnitId,
                       let newDate = pendingKeyDate {
                        
                        // ✅ use normalized UTC midnight
                        let normalized = utcMidnightForLocalDate(newDate)
                        
                        await complaintListViewModel.updateUnitKeyDate(
                            unitId: unitId,
                            newKeyDate: normalized
                        )
                        
                        guard var selectedUnit = unitViewModel.claimedUnits.first(where: { $0.id == unitId }) else {
                            print("Error: Could not find the selected unit.")
                            return
                        }
                        
                        guard let userId = userId else {
                            print("Error: userId is nil")
                            return
                        }
                        
                        await performComplaintSubmission(selectedUnit: &selectedUnit, unitId: unitId, userId: userId)
                    }
                }
            }
        } message: {
            let existingDateStr = existingKeyDate?.formatted(date: .abbreviated, time: .omitted) ?? "None"
            let newDateStr = pendingKeyDate?.formatted(date: .abbreviated, time: .omitted) ?? "None"
            
            return Text("There are complaints under review by BSC with a different key handover date (\(existingDateStr)). Do you want to update the unit's key handover date to \(newDateStr)?")
        }
        .onAppear {
            userId = NetworkManager.shared.getUserIdFromToken()
        }
        .navigationTitle("Key Handover")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Complaint Submitted", isPresented: $showingSuccessAlert) {
            Button("OK") {
               // onComplaintSubmitted()
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
            backgroundColor: .primaryBlue,
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

        guard var selectedUnit = unitViewModel.claimedUnits.first(where: { $0.id == unitId }) else {
            print("Error: Could not find the selected unit.")
            return
        }

        Task {
            let conflict = await checkForKeyDateConflict(unitId: unitId, newKeyDate: selectedDate)
            
            if conflict.hasConflict {
                await MainActor.run {
                    pendingKeyDate = selectedDate
                    existingKeyDate = conflict.existingDate
                    showKeyDateConflictAlert = true
                }
            } else {
                await performComplaintSubmission(selectedUnit: &selectedUnit, unitId: unitId, userId: userId)
            }
        }
    }

    private func performComplaintSubmission(selectedUnit: inout Unit2, unitId: String, userId: String) async {

        // ✅ normalize to midnight UTC
        let normalizedDate = utcMidnightForLocalDate(selectedDate)


        selectedUnit.keyHandoverDate = normalizedDate
        selectedUnit.keyHandoverNote = additionalNotes.isEmpty ? nil : additionalNotes

        let fixedStatusId = "661a5a05-730b-4dc3-a924-251a1db7a2d7"

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
            keyHandoverDate: normalizedDate,
            keyHandoverNote: additionalNotes.isEmpty ? nil : additionalNotes
        )

        do {
            await complaintViewModel.submitComplaint(request: request, selectedUnit: selectedUnit)
            await MainActor.run {
                showingSuccessAlert = true
                onComplaintSubmitted()
            }
        } catch {
            print("Failed to submit complaint: \(error)")
        }
    }
    
    private func checkForKeyDateConflict(unitId: String, newKeyDate: Date) async -> (hasConflict: Bool, existingDate: Date?) {
        await complaintListViewModel.loadComplaints(byUnitId: unitId)

        let hasUnderReviewComplaints = complaintListViewModel.complaints.contains {
            $0.unitId == unitId && $0.statusName?.lowercased() == "under review by bsc"
        }

        guard hasUnderReviewComplaints else {
            return (false, nil)
        }

        do {
            let unit = try await unitViewModel.getUnitById(unitId)
            let existingKeyDate = unit.keyHandoverDate
            
            if let existing = existingKeyDate {
                let sameDay = Calendar.current.isDate(existing, inSameDayAs: newKeyDate)
                return (!sameDay, existing)
            } else {
                return (false, nil)
            }
        } catch {
            print("Failed to get unit for key date check: \(error)")
            return (false, nil)
        }
    }
    
    // ✅ New helper
    private func utcMidnightForLocalDate(_ date: Date) -> Date {
        let localCal = Calendar.current
        let comps = localCal.dateComponents([.year, .month, .day], from: date)
        
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(secondsFromGMT: 0)!
        
        if let utcMidnight = utcCal.date(from: comps) {
            return utcMidnight
        } else {
            return localCal.startOfDay(for: date)
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
        complaintListViewModel: ResidentComplaintListViewModel(),
        onComplaintSubmitted: { print("Complaint submitted callback") }
    )
}
