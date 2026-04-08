//
//  Theme.swift
//  BasicWaterTracker
//
//  Shared color styling for light and dark mode
//

import SwiftUI

struct AppBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [
                        Color(red: 32.0 / 255.0, green: 45.0 / 255.0, blue: 40.0 / 255.0), // top left
                        Color(red: 41.0 / 255.0, green: 42.0 / 255.0, blue: 48.0 / 255.0), // main color
                        Color(red: 50.0 / 255.0, green: 40.0 / 255.0, blue: 36.0 / 255.0) //bottom right
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 220.0 / 255.0, green: 238.0 / 255.0, blue: 246.0 / 255.0), // top left
                        Color(red: 230.0 / 255.0, green: 236.0 / 255.0, blue: 249.0 / 255.0), // main color
                        Color(red: 243.0 / 255.0, green: 234.0 / 255.0, blue: 246.0 / 255.0) //bottom right
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .ignoresSafeArea()
    }
}