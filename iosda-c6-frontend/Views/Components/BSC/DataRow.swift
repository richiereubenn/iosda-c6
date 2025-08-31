//
//  DataRow.swift
//  iosda-c6-frontend
//
//  Created by Richie Reuben Hermanto on 01/09/25.
//

import SwiftUI

struct DataRowComponent: View {
    let label: String
    let value: String
    let labelColor: Color
    let valueColor: Color
    
    init(label: String, value: String, labelColor: Color = .gray, valueColor: Color = .black) {
        self.label = label
        self.value = value
        self.labelColor = labelColor
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(labelColor)
                .font(.system(size: 14))
            
            Text(value)
                .foregroundColor(valueColor)
                .font(.system(size: 14, weight: .medium))
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 12) {
        DataRowComponent(label: "Nama", value: "Richie Hermanto")
    }
    .padding()
    .previewLayout(.sizeThatFits)
}

