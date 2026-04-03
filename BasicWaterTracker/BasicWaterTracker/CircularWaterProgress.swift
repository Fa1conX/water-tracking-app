//
//  CircularWaterProgress.swift
//  BasicWaterTracker
//
//  Circular progress indicator for water intake tracking
//

import SwiftUI

struct CircularWaterProgress: View {
    let currentAmount: Double
    let dailyGoal: Double

    var rawProgress: Double {
        guard dailyGoal > 0 else { return 0 }
        return currentAmount / dailyGoal
    }
    
    var progress: Double {
        min(rawProgress, 1.0)
    }
    
    var percentage: Int {
        Int((rawProgress * 100).rounded())
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Date and percentage
            VStack(spacing: 4) {
                Text("Today")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("\(percentage)%")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            // Circular progress ring
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color(.systemGray6), lineWidth: 12)
                
                // Progress circle (filled from bottom all the way around)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color(red: 0.3, green: 0.7, blue: 1.0),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(270))
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                // Center text - amount centered, oz below
                Text("\(String(format: "%.1f", currentAmount))")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                
                // oz label offset below
                Text("oz")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray)
                    .offset(y: 32)
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: 200)
        }
    }
}

#Preview {
    CircularWaterProgress(currentAmount: 24, dailyGoal: 64)
        .padding()
}
