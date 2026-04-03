//
//  BasicWaterTrackerApp.swift
//  BasicWaterTracker
//
//  Created by Karsten H on 4/2/26.
//

import SwiftUI

@main
struct BasicWaterTrackerApp: App {
    @StateObject private var viewModel = WaterTrackingViewModel()
    @State private var showSplash = true
    @State private var minimumTimeElapsed = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(viewModel)
                
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .onAppear {
                            // Set flag after minimum 1 second
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                minimumTimeElapsed = true
                                checkShouldDismiss()
                            }
                        }
                        .onChange(of: viewModel.isLoaded) { _ in
                            checkShouldDismiss()
                        }
                }
            }
        }
    }
    
    private func checkShouldDismiss() {
        if minimumTimeElapsed && viewModel.isLoaded {
            withAnimation(.easeOut(duration: 0.5)) {
                showSplash = false
            }
        }
    }
}
