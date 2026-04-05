//
//  BasicWaterTrackerApp.swift
//  BasicWaterTracker
//
//  Created by Karsten H on 4/2/26.
//

import SwiftUI
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Request notification permissions
        NotificationManager.shared.requestNotificationPermission { granted in
            print("Notification permission granted: \(granted)")
        }
        return true
    }
    
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        [.portrait, .portraitUpsideDown]
    }
}

@main
struct BasicWaterTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = WaterTrackingViewModel()
    @State private var showSplash = true
    @State private var minimumTimeElapsed = false
    @State private var splashOpacity: Double = 1.0
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(viewModel)
                
                if showSplash {
                    SplashScreenView()
                        .opacity(splashOpacity)
                        .onAppear {
                            // Set flag after minimum 1 second
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                minimumTimeElapsed = true
                                checkShouldDismiss()
                            }
                        }
                        .onChange(of: viewModel.isLoaded) {
                            checkShouldDismiss()
                        }
                }
            }
        }
    }
    
    private func checkShouldDismiss() {
        if minimumTimeElapsed && viewModel.isLoaded {
            withAnimation(.easeOut(duration: 0.75)) {
                splashOpacity = 0.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                showSplash = false
            }
        }
    }
}
