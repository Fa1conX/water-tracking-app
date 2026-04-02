//
//  ContentView.swift
//  BasicWaterTracker
//
//  Main view showing water intake tracking
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: WaterTrackingViewModel
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Light grey background
            Color(red: 0.1608, green: 0.1647, blue: 0.1686)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with settings
                HStack {
                    Text("Water Tracker")
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Circular progress with +/- buttons
                        HStack(alignment: .circleCenter, spacing: 30) {
                            // Minus button
                            Button(action: {
                                if viewModel.getTdayTotal() > 0 {
                                    viewModel.removeLastEntry()
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            .alignmentGuide(.circleCenter) { d in d[VerticalAlignment.center] }
                            
                            // Circular progress indicator
                            CircularWaterProgress(
                                currentAmount: viewModel.getTdayTotal(),
                                dailyGoal: viewModel.dailyGoal
                            )
                            .frame(maxWidth: 200)
                            .alignmentGuide(.circleCenter) { d in d[VerticalAlignment.center] + 50 }
                            
                            // Plus button
                            Button(action: {
                                if !viewModel.presets.isEmpty {
                                    viewModel.addWaterEntry(amount: viewModel.presets[0])
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            .alignmentGuide(.circleCenter) { d in d[VerticalAlignment.center] }
                        }
                        .padding()
                        
                        // Quick add buttons (3 in a row)
                        HStack(spacing: 12) {
                            ForEach(viewModel.presets, id: \.self) { preset in
                                Button(action: {
                                    viewModel.addWaterEntry(amount: preset)
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "drop.fill")
                                            .font(.system(size: 14))
                                        
                                        Text("\(String(format: "%.0f", preset))")
                                            .font(.system(size: 12, weight: .semibold))
                                        
                                        Text("oz")
                                            .font(.system(size: 10))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // Today's entries
                        if !viewModel.getTodayEntries().isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's Log")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(.horizontal)
                                
                                VStack(spacing: 8) {
                                    ForEach(viewModel.getTodayEntries()) { entry in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("\(String(format: "%.1f", entry.amount)) oz")
                                                    .font(.system(size: 14, weight: .semibold))
                                                Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                viewModel.removeEntry(entry)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .font(.system(size: 16))
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.1608, green: 0.1647, blue: 0.1686))
                }
                .background(Color(red: 0.1608, green: 0.1647, blue: 0.1686))
            }
            .background(Color(red: 0.1608, green: 0.1647, blue: 0.1686))
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension VerticalAlignment {
    private struct CircleCenter: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }
    
    static let circleCenter = VerticalAlignment(CircleCenter.self)
}

#Preview {
    ContentView()
        .environmentObject(WaterTrackingViewModel())
}
