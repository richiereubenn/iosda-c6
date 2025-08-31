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
    
    init(text: String, backgroundColor: Color = .blue, textColor: Color = .white, action: @escaping () -> Void) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(textColor)
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(backgroundColor)
                .cornerRadius(8)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CustomButtonComponent(text: "Default Button") {
            print("Default button tapped")
        }
        
        CustomButtonComponent(text: "Red Button", backgroundColor: .red, textColor: .white) {
            print("Red button tapped")
        }
        
        CustomButtonComponent(text: "Green Text Button", backgroundColor: .gray, textColor: .green) {
            print("Green text button tapped")
        }
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
