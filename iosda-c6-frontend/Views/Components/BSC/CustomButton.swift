//
//  CustomButton.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

struct CustomButtonComponent: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color
    let action: () -> Void
    let isDisabled: Bool
    
    init(
        text: String,
        backgroundColor: Color = .blue,
        textColor: Color = .white,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(isDisabled ? .gray.opacity(0.7) : textColor)
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isDisabled ? Color.gray.opacity(0.3) : backgroundColor)
                .cornerRadius(8)
        }
        .disabled(isDisabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        CustomButtonComponent(text: "Enabled Button") {
            print("Enabled button tapped")
        }
        
        CustomButtonComponent(text: "Disabled Button", backgroundColor: .red, isDisabled: true) {
            print("Disabled button tapped")
        }
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
