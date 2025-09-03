//
//  RequirementsCheckbox.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

struct RequirementsCheckbox: View {
    let text: String
    let isChecked: Bool
    let onToggle: (() -> Void)?
    
    init(text: String, isChecked: Bool, onToggle: (() -> Void)? = nil) {
        self.text = text
        self.isChecked = isChecked
        self.onToggle = onToggle
    }
    
    var body: some View {
        HStack {
            Button(action: {
                onToggle?()
            }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? .primaryBlue : .secondary)
                    .font(.system(size: 20))
            }
            .disabled(onToggle == nil)
            
            Text(text)
                .foregroundColor(.primary) 
                .font(.system(size: 14))
            
            Spacer()
        }
    }
}

struct RequirementsCheckbox_PreviewContainer: View {
    @State private var checked1 = true
    @State private var checked2 = false

    var body: some View {
        VStack(spacing: 16) {
            RequirementsCheckbox(text: "Setuju dengan syarat dan ketentuan", isChecked: checked1) {
                checked1.toggle()
            }

            RequirementsCheckbox(text: "Menyetujui privacy policy", isChecked: checked2) {
                checked2.toggle()
            }
        }
        .padding()
    }
}

#Preview {
    Group {
        RequirementsCheckbox_PreviewContainer()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)

        RequirementsCheckbox_PreviewContainer()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
