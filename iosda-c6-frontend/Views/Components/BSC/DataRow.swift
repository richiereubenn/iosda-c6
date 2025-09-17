import SwiftUI

struct DataRowComponent: View {
    let label: String
    let value: String
    let labelColor: Color
    let valueColor: Color
    
    init(
        label: String,
        value: String,
        labelColor: Color = .secondary,
        valueColor: Color = .primary
    ) {
        self.label = label
        self.value = value
        self.labelColor = labelColor
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(label)
                .foregroundColor(labelColor)
                .font(.subheadline)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            Text(value)
                .foregroundColor(valueColor)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    Group {
        VStack(spacing: 12) {
            DataRowComponent(label: "Nama", value: "Richie Hermanto")
            DataRowComponent(label: "Status", value: "Aktif")
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.light)
        
        VStack(spacing: 12) {
            DataRowComponent(label: "Nama", value: "Richie Hermanto")
            DataRowComponent(label: "Status", value: "Aktif")
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
        
        VStack(spacing: 12) {
            DataRowComponent(label: "Nama", value: "Richie Hermanto")
            DataRowComponent(label: "Status", value: "Aktif")
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
    }
}
