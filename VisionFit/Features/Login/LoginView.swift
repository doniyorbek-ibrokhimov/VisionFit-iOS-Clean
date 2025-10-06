//
//  LoginView.swift
//  VisionFit
//
//  Created by Doniyorbek Ibrokhimov on 20/12/24.
//

import SwiftUI

struct LoginView: View {
    @State private var firstName: String = ""
    @State private var secondName: String = ""
    @State private var navigateToHome = false
    
    // Button background color as specified
    let buttonColor = Color(hex: "032B44")
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Login")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: "person.circle")
                        .font(.title)
                }
                
                Text("Welcome to VisionFit")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top)
            
            Spacer()
                .frame(height: 20)
            
            // Illustration
            Image(.workoutIllustration)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 170)
                    .padding(.horizontal)
            
            Spacer()
                .frame(height: 40)
                
            // Form section
            VStack(spacing: 20) {
                Text("Type your name")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                TextField("First name", text: $firstName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                TextField("Second name", text: $secondName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Text("Need help ?")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Login button
                Button(action: {
                    navigateToHome = true
                }) {
                    Text("Login")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(buttonColor)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 15)
                .navigationDestination(isPresented: $navigateToHome) {
                    HomeView()
                }
                
                // Indicator dots - for onboarding
                HStack(spacing: 8) {
                    ForEach(0..<2) { _ in
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                    
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 20, height: 6)
                        .cornerRadius(3)
                }
                .padding(.bottom, 20)
            }
        }
    }
}
