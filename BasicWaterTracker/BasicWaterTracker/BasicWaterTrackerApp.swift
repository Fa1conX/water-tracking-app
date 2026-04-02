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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
