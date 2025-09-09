import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    // Background logo watermark
                    Image("ciputra_logo")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.05)
                        .frame(width: geo.size.width * 1.4)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2) // center watermark
                    
                    VStack(alignment: .leading, spacing: 0) {
                        // Back button
                        HStack {
                            Button(action: {
                                // dismiss or pop action if needed
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            Spacer()
                        }
                        .padding(.top, 12)
                        .padding(.leading, 24)
                        
                        // Title
                        Text("Login to Ciputra Help")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.top, 10)
                            .padding(.horizontal, 24)
                        
                        // Username TextField
                        TextField("Username / Phone Number", text: $viewModel.username)
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.top, 15)
                            .padding(.horizontal, 20)
                        
                        // Password SecureField
                        SecureField("Password", text: $viewModel.password)
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.top, 12)
                            .padding(.horizontal, 20)
                        
                        // Show error message if any
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                                .padding(.top, 8)
                                .padding(.horizontal, 20)
                        }
                        
                        // Sign up row with NavigationLink
                        HStack(spacing: 4) {
                            Spacer()
                            Text("Don’t have account ?")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            NavigationLink(destination: RegisterView()) {
                                Text("Sign Up")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 0, green: 130/255, blue: 124/255))
                            }
                        }
                        .padding(.top, 12)
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40) // controlled space before button
                        
                        // Continue button
                        Button(action: {
                            viewModel.login()
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
                .navigationDestination(isPresented: Binding(
                    get: { viewModel.loggedInUser != nil },
                    set: { _ in }
                )) {
                    roleBasedView(for: viewModel.loggedInUser?.role?.name)
                }
            }
        }
    }
    
    @ViewBuilder
    func roleBasedView(for roleName: String?) -> some View {
        switch roleName?.lowercased() {
        case "bsc":
            BSCContentView()
        case "bi":
            BIContentView()
        case "resident":
            ResidentContentView()
        default:
            Text("Unknown role.")
        }
    }
}

#Preview {
    LoginView()
}
