import SwiftUI

struct ResidentKeyDateView: View {
    var handoverMethod: String
    var selectedUnitId: Int?
    var complaintTitle: String
    var complaintDetails: String
    
    @ObservedObject var unitViewModel: UnitViewModel
    @ObservedObject var complaintViewModel: ComplaintListViewModel
    
    var onComplaintSubmitted: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var additionalNotes: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showingSuccessAlert = false
    
    private let dayAfterTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
    
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
            Text(handoverMethod)
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
        print("PrimaryButton tapped")
        guard let unitId = selectedUnitId else {
            print("unitId is nil")
            return
        }

        let request = CreateComplaintRequest(
            unitId: unitId,
            title: complaintTitle,
            description: complaintDetails + "\nNotes: \(additionalNotes)",
            classificationId: nil,
            keyHandoverDate: selectedDate,
            latitude: nil,
            longitude: nil,
            handoverMethod: handoverMethod
        )

        Task {
            do {
                print("Submitting complaint...")
                try await complaintViewModel.submitComplaint(request: request, unitViewModel: unitViewModel)
                await MainActor.run {
                    print("Submitted successfully")
                    // Ensure the filter is set to open to show the new complaint
                    //complaintViewModel.selectedFilter = .open
                    //complaintViewModel.filterComplaints()
                    showingSuccessAlert = true
                }
            } catch {
                print("Failed to submit complaint: \(error)")
                // You might want to show an error alert here too
            }
        }
    }
    
}



#Preview {
    ResidentKeyDateView(
        handoverMethod: "Bring to MO",
        selectedUnitId: 1,
        complaintTitle: "Leaky Faucet",
        complaintDetails: "Water leaking from kitchen faucet.",
        unitViewModel: UnitViewModel(),
        complaintViewModel: ComplaintListViewModel(),
        onComplaintSubmitted: { print("Complaint submitted callback") }
    )
}
