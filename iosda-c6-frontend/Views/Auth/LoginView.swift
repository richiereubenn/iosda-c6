import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showPassword = false
    @State private var goToNext = false
    @State private var goToRegister = false

    
    var body: some View {
        NavigationStack{
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
                                goToRegister = true
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.primaryBlue)
                        }
                        .padding(.top, 12)
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                        
                        // Continue button
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.gray)
                                .cornerRadius(12)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)
                        } else {
                            CustomButtonComponent(
                                text: "Continue",
                                backgroundColor: viewModel.isFormValid ? .primaryBlue : .gray.opacity(0.4),
                                isDisabled: !viewModel.isFormValid || viewModel.isLoading
                            ) {
                                viewModel.login()
                                if viewModel.loggedInUser != nil {
                                    goToNext = true
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)
                        }
                        
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
            .navigationDestination(isPresented: $goToRegister) {
                RegisterView()
            }
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
