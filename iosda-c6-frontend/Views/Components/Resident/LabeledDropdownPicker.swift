import SwiftUI

struct LabeledDropdownPicker: View {
    let label: String?
    let placeholder: String
    @Binding var selection: String
    let options: [String]
    var isDisabled: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let label = label{
                Text(label)
                    .font(.headline)
            }

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? placeholder : selection)
                        .foregroundColor(selection.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1)
        }
    }
}
