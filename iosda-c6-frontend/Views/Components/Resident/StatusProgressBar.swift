//import SwiftUI
//
//struct StatusProgressBar: View {
//    // 1. The input is now a simple String optional, matching `complaint.statusName`.
//    let currentStatusName: String?
//
//    // 2. The internal steps now use strings for identification instead of the old enum.
//    // We use snake_case to match the API response style.
//    private let statusSteps: [(statusName: String, title: String, stepNumber: Int)] = [
//        ("under_review", "On Review", 1),
//        ("waiting_key", "Key Handover", 2),
//        ("in_progress", "In Progress", 3),
//        ("resolved", "Done", 4)
//    ]
//
//    var body: some View {
//        // 3. Logic is updated to work with strings.
//        // It treats "open" as "under_review" for display purposes.
//        let effectiveStatusName: String? = {
//            let lowercasedStatus = currentStatusName?
//                .lowercased()
//                .replacingOccurrences(of: " ", with: "_")
//            
//            if lowercasedStatus == "open" {
//                return "under_review"
//            }
//            return lowercasedStatus
//        }()
//
//        HStack(spacing: 0) {
//            ForEach(Array(statusSteps.enumerated()), id: \.offset) { index, step in
//                VStack(spacing: 8) {
//                    ZStack {
//                        Circle()
//                            .fill(isStepCompleted(step.statusName, effectiveStatusName: effectiveStatusName) ? Color.blue : Color.gray.opacity(0.3))
//                            .frame(width: 40, height: 40)
//
//                        if isStepCompleted(step.statusName, effectiveStatusName: effectiveStatusName) {
//                            if step.statusName == effectiveStatusName {
//                                Text("\(step.stepNumber)")
//                                    .foregroundColor(.white)
//                                    .fontWeight(.bold)
//                            } else {
//                                Image(systemName: "checkmark")
//                                    .foregroundColor(.white)
//                                    .fontWeight(.bold)
//                            }
//                        } else {
//                            Text("\(step.stepNumber)")
//                                .foregroundColor(.gray)
//                                .fontWeight(.bold)
//                        }
//                    }
//
//                    Text(step.title)
//                        .font(.caption)
//                        .foregroundColor(isStepCompleted(step.statusName, effectiveStatusName: effectiveStatusName) ? .primary : .gray)
//                        .multilineTextAlignment(.center)
//                        .frame(maxWidth: .infinity)
//                }
//
//                if index < statusSteps.count - 1 {
//                    Rectangle()
//                        .fill(isStepCompleted(statusSteps[index + 1].statusName, effectiveStatusName: effectiveStatusName) ? Color.blue : Color.gray.opacity(0.3))
//                        .frame(height: 2)
//                        .padding(.bottom, 30)
//                }
//            }
//        }
//    }
//
//    // 4. The helper function is now fully string-based.
//    private func isStepCompleted(_ stepStatusName: String, effectiveStatusName: String?) -> Bool {
//        guard let effectiveStatusName = effectiveStatusName,
//              let currentIndex = statusSteps.firstIndex(where: { $0.statusName == effectiveStatusName }) else {
//            return false
//        }
//        
//        guard let stepIndex = statusSteps.firstIndex(where: { $0.statusName == stepStatusName }) else {
//            return false
//        }
//
//        return stepIndex <= currentIndex
//    }
//}

import SwiftUI

struct StatusProgressBar: View {
    let currentStatusName: String?

    // Group the detailed statuses into broader steps
    private let stepGroups: [(stepName: String, title: String, statuses: [String])] = [
        ("under_review", "Under Review", ["under review by bsc"]),
        ("key_handover", "Key Handover", ["waiting key handover"]),
        ("in_progress", "In Progress", ["in progress", "assign to vendor", "under review by bi"]),
        ("done", "Done", ["resolved", "rejected", "closed"])
    ]

    var body: some View {
        let effectiveStepIndex = currentStepIndex(for: currentStatusName)

        HStack(spacing: 0) {
            ForEach(Array(stepGroups.enumerated()), id: \.offset) { index, step in
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(index <= effectiveStepIndex ? Color.primaryBlue : Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)

                        if index < effectiveStepIndex {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        } else if index == effectiveStepIndex {
                            Text("\(index + 1)")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        } else {
                            Text("\(index + 1)")
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                        }
                    }

                    Text(step.title)
                        .font(.caption)
                        .foregroundColor(index <= effectiveStepIndex ? .primary : .gray)
                        .multilineTextAlignment(.center)
                        .frame(width: 60, height: 32)
                }
                .frame(height: 100)

                if index < stepGroups.count - 1 {
                    Rectangle()
                        .fill((index + 1) <= effectiveStepIndex ? Color.primaryBlue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .padding(.bottom, 30)
                }
            }
        }
        .padding()
    }

    private func currentStepIndex(for statusName: String?) -> Int {
        guard let status = statusName?.lowercased() else { return -1 }

        // Find the index of the step group that contains this status
        for (index, group) in stepGroups.enumerated() {
            if group.statuses.contains(where: { $0.lowercased() == status }) {
                return index
            }
        }

        // If not found, return -1 so no steps are completed
        return -1
    }
}
