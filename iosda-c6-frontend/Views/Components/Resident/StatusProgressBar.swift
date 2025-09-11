import SwiftUI

struct StatusProgressBar: View {
    // 1. The input is now a simple String optional, matching `complaint.statusName`.
    let currentStatusName: String?

    // 2. The internal steps now use strings for identification instead of the old enum.
    // We use snake_case to match the API response style.
    private let statusSteps: [(statusName: String, title: String, stepNumber: Int)] = [
        ("under_review", "On Review", 1),
        ("waiting_key", "Key Handover", 2),
        ("in_progress", "In Progress", 3),
        ("resolved", "Done", 4)
    ]

    var body: some View {
        // 3. Logic is updated to work with strings.
        // It treats "open" as "under_review" for display purposes.
        let effectiveStatusName: String? = {
            let lowercasedStatus = currentStatusName?
                .lowercased()
                .replacingOccurrences(of: " ", with: "_")
            
            if lowercasedStatus == "open" {
                return "under_review"
            }
            return lowercasedStatus
        }()

        HStack(spacing: 0) {
            ForEach(Array(statusSteps.enumerated()), id: \.offset) { index, step in
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(isStepCompleted(step.statusName, effectiveStatusName: effectiveStatusName) ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)

                        if isStepCompleted(step.statusName, effectiveStatusName: effectiveStatusName) {
                            if step.statusName == effectiveStatusName {
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
                        .foregroundColor(isStepCompleted(step.statusName, effectiveStatusName: effectiveStatusName) ? .primary : .gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                if index < statusSteps.count - 1 {
                    Rectangle()
                        .fill(isStepCompleted(statusSteps[index + 1].statusName, effectiveStatusName: effectiveStatusName) ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .padding(.bottom, 30)
                }
            }
        }
    }

    // 4. The helper function is now fully string-based.
    private func isStepCompleted(_ stepStatusName: String, effectiveStatusName: String?) -> Bool {
        guard let effectiveStatusName = effectiveStatusName,
              let currentIndex = statusSteps.firstIndex(where: { $0.statusName == effectiveStatusName }) else {
            return false
        }
        
        guard let stepIndex = statusSteps.firstIndex(where: { $0.statusName == stepStatusName }) else {
            return false
        }

        return stepIndex <= currentIndex
    }
}
