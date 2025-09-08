import SwiftUI

struct StatusProgressBar: View {
    let currentStatus: Status?

    private let statusSteps: [(statusID: Status.ComplaintStatusID, title: String, stepNumber: Int)] = [
        (.underReview, "On Review", 1),
        (.waitingKey, "Key Handover", 2),
        (.inProgress, "In Progress", 3),
        (.resolved, "Done", 4)
    ]

    var body: some View {
        let effectiveStatusID: Status.ComplaintStatusID? = {
            if let current = currentStatus?.complaintStatusID {
                return current == .open ? .underReview : current
            }
            return nil
        }()

        HStack(spacing: 0) {
            ForEach(Array(statusSteps.enumerated()), id: \.offset) { index, step in
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(isStepCompleted(step.statusID, effectiveStatusID: effectiveStatusID) ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)

                        if isStepCompleted(step.statusID, effectiveStatusID: effectiveStatusID) {
                            if step.statusID == effectiveStatusID {
                                Text("\(step.stepNumber)")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            } else {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        } else {
                            Text("\(step.stepNumber)")
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                    }

                    Text(step.title)
                        .font(.caption)
                        .foregroundColor(isStepCompleted(step.statusID, effectiveStatusID: effectiveStatusID) ? .primary : .gray)
                        .multilineTextAlignment(.center)
                }

                if index < statusSteps.count - 1 {
                    Rectangle()
                        .fill(isStepCompleted(statusSteps[index + 1].statusID, effectiveStatusID: effectiveStatusID) ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 30)
                }
            }
        }
    }

    // ✅ --- THIS FUNCTION IS NOW FIXED ---
    private func isStepCompleted(_ statusID: Status.ComplaintStatusID, effectiveStatusID: Status.ComplaintStatusID?) -> Bool {
        // Safely find the index for the current status. If it's not a progress step, we can't compare.
        guard let effectiveStatusID = effectiveStatusID,
              let currentIndex = statusSteps.firstIndex(where: { $0.statusID == effectiveStatusID }) else {
            return false
        }
        
        // Safely find the index for the step we are checking.
        guard let stepIndex = statusSteps.firstIndex(where: { $0.statusID == statusID }) else {
            return false
        }

        return stepIndex <= currentIndex
    }
}
