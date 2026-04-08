//
//  Theme.swift
//  BasicWaterTracker
//
//  Shared color styling for light and dark mode
//

import SwiftUI

extension Color {
    static var appBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.1608, green: 0.1647, blue: 0.1686, alpha: 1.0)
                : UIColor(red: 230.0 / 255.0, green: 236.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
        })
    }
}