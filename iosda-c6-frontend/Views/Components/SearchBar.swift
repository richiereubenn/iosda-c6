
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            // Left magnifying glass
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            // Text field
            TextField("Search", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
            
            // Right microphone icon
            Button(action: {
                // microphone action here
            }) {
                Image(systemName: "mic.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(Color(.systemGray6)) // light gray bg
        .cornerRadius(7) // rounded corners
        .padding(.horizontal)
    }
}

struct search: View {
    @State private var searchText: String = ""
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
            
            Spacer()
        }
    }
}

#Preview {
    search()
}
