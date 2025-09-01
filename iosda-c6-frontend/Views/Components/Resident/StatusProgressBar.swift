//
//  StatusProgressView.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 01/09/25.
//


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

    private func isStepCompleted(_ statusID: Status.ComplaintStatusID, effectiveStatusID: Status.ComplaintStatusID?) -> Bool {
        guard let effectiveStatusID else { return false }

        let currentIndex = statusSteps.firstIndex { $0.statusID == effectiveStatusID } ?? 0
        let stepIndex = statusSteps.firstIndex { $0.statusID == statusID } ?? 0

        return stepIndex <= currentIndex
    }
}
