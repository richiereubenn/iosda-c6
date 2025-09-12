import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showPassword = false
    @State private var goToNext = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background logo watermark
                Image("ciputra_logo")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.05)
                    .frame(width: geo.size.width * 1.4)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2) // center watermark
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("Login to Ciputra Help")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 10)
                        .padding(.horizontal, 24)
                    
                    // Username
                    TextField("Username / Phone Number", text: $viewModel.username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.top, 15)
                        .padding(.horizontal)
                        .autocapitalization(.none)
                    
                    // Password
                    ZStack(alignment: .trailing) {
                        if showPassword {
                            TextField("Password", text: $viewModel.password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        } else {
                            SecureField("Password", text: $viewModel.password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    }
                    .padding()
                    
                    // Error message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.top, 8)
                            .padding(.horizontal, 20)
                    }
                    
                    // Sign up row
                    HStack(spacing: 4) {
                        Spacer()
                        Text("Don’t have account ?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Button("Sign Up") {
                            // present register
                        }
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0, green: 130/255, blue: 124/255))
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                    
                    // Continue button
                    Button(action: {
                        viewModel.login()
                        if viewModel.loggedInUser != nil {
                            goToNext = true
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(.blue))
                                .cornerRadius(12)
                        } else {
                            Text("Continue")
                                .font(.system(size: 16, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(viewModel.isFormValid ? Color(.blue) : Color.gray.opacity(0.4))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.loggedInUser != nil },
            set: { _ in }
        )) {
            roleBasedView()
        }
    }
    
    @ViewBuilder
    func roleBasedView() -> some View {
        if let user = viewModel.loggedInUser,
           let role = user.role {
            
            let roleName = role.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            switch roleName {
            case "bsc":
                BSCContentView()
            case "bi":
                BIContentView()
            case "resident":
                ResidentContentView()
            default:
                VStack {
                    Text("Unknown role: '\(role.name)'")
                    Text("Role ID: \(role.id ?? "N/A")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        } else {
            Text("No user or role information available")
        }
    }
}
