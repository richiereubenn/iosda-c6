//
//  ComplainDecision.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

enum DecisionType {
    case accept
    case reject
    
    var backgroundColor: Color {
        switch self {
        case .accept:
            return .green
        case .reject:
            return .red
        }
    }
    
    var text: String {
        switch self {
        case .accept:
            return "Complain Accept"
        case .reject:
            return "Complain Reject"
        }
    }
}

struct ComplainDecision: View {
    let decision: DecisionType
    let onTap: (() -> Void)?
    
    init(decision: DecisionType, onTap: (() -> Void)? = nil) {
        self.decision = decision
        self.onTap = onTap
    }
    
    var body: some View {
        HStack {
            Text("Decision :")
                .foregroundColor(.gray)
                .font(.system(size: 14))
            
            
            Button(action: {
                onTap?()
            }) {
                Text(decision.text)
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(decision.backgroundColor)
                    .cornerRadius(6)
            }
            .disabled(onTap == nil)
            
            
            Spacer()
        }
    }
}

struct ComplainDecision_PreviewContainer: View {
    var body: some View {
        VStack(spacing: 16) {
            ComplainDecision(decision: .accept) {
                print("Complain accepted")
            }
            
            ComplainDecision(decision: .reject) {
                print("Complain rejected")
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

#Preview {
    ComplainDecision_PreviewContainer()
}

