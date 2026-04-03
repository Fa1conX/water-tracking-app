//
//  SplashScreenView.swift
//  BasicWaterTracker
//
//  Splash screen shown while app loads
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.1608, green: 0.1647, blue: 0.1686)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // App icon
                Image("WaterDropletLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                
                Text("Water Tracker")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.blue)
                    .padding(.top, -20)
                
                Spacer()
            }
            .opacity(opacity)
        }
        .onAppear {
            // Scale and fade in animation
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
            
            // Fade out animation after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.8)) {
                    opacity = 0.0
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
