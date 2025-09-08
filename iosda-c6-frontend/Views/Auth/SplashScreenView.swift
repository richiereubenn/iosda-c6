//
//  SplashScreenView.swift
//  iosda-c6-frontend
//
//  Created by Gabriella Natasya Pingky Davis on 08/09/25.
//



import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            if isActive {
                // Transition to LoginView with smooth fade
                LoginView()
                    .transition(.opacity)
            } else {
                Color.white
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Logo + title
                    VStack(spacing: -20) {
                        Image("logo ciputra")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                        
                        Text("Ciputra Help")
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(Color(red: 0/255, green: 56/255, blue: 123/255))
                    }
                    
                    Spacer()
                    
                    // Progress bar + version text
                    VStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .frame(height: 4)
                                    .foregroundColor(Color.gray.opacity(0.2))
                                
                                Capsule()
                                    .frame(width: geo.size.width * progress, height: 4)
                                    .foregroundColor(Color("ciputrablue"))
                                    .animation(.linear(duration: 2), value: progress)
                            }
                        }
                        .frame(width: 120, height: 4) // bar width
                        
                        Text("1.0.0")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .onAppear {
            // Reset progress
            progress = 0.0
            
            // Animate progress smoothly left → right
            withAnimation(.linear(duration: 2)) {
                progress = 1.0
            }
            
            // Switch to LoginView after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut) {
                    isActive = true
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SplashScreenView()
        }
    }
}






