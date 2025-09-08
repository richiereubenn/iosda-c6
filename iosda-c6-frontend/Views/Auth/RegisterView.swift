import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @State private var showPassword = false
    
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 20) {
                
                // Title
                Text("Register to\nCiputra Help")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Form Fields
                //Group {
                TextField("Name", text: $viewModel.name)
                    .padding().background(Color(.systemGray6)).cornerRadius(8)
                TextField("Email", text: $viewModel.email)
                    .padding().background(Color(.systemGray6)).cornerRadius(8)
                TextField("Phone Number", text: $viewModel.phone)
                    .padding().background(Color(.systemGray6)).cornerRadius(8)
                TextField("Username", text: $viewModel.username)
                    .padding().background(Color(.systemGray6)).cornerRadius(8)
                
                ZStack(alignment: .trailing) {
                    if showPassword {
                        TextField("Password", text: $viewModel.password)
                            .padding().background(Color(.systemGray6)).cornerRadius(8)
                    } else {
                        SecureField("Password", text: $viewModel.password)
                            .padding().background(Color(.systemGray6)).cornerRadius(8)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray).padding(.trailing, 12)
                    }
                }
                //}
                
                HStack(alignment: .top, spacing: 10) {
                    Checkbox(isOn: $viewModel.acceptedTerms)
                    (
                        Text("I Accept the ") +
                        Text("terms and conditions").foregroundColor(.blue).underline() +
                        Text(" as well as the ") +
                        Text("privacy policy").foregroundColor(.blue).underline()
                    )
                }
                .font(.system(size: 14))
                
                // Display error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    // Trigger the network request from the view model
                    viewModel.registerUser()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isFormValid ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
            }
            
            .padding()
            .alert("Registration Success", isPresented: $viewModel.registrationSuccess) {
                Button("OK", role: .cancel) {
                    // Handle post-registration logic, like navigating back or to a new view
                }
            }
        }
    }
}

// MARK: - Custom Components
struct Checkbox: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            Image(systemName: isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(isOn ? .blue : .gray)
                .font(.system(size: 22))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RegisterView()
}
