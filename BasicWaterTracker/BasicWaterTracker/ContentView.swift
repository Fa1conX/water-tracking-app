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
            Color(red: 0.94, green: 0.94, blue: 0.96)
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
                        HStack(spacing: 30) {
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
                            
                            // Circular progress indicator
                            CircularWaterProgress(
                                currentAmount: viewModel.getTdayTotal(),
                                dailyGoal: viewModel.dailyGoal
                            )
                            .frame(maxWidth: 200)
                            
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
                        }
                        .padding()
                        
                        // Quick add buttons
                        VStack(spacing: 12) {
                            ForEach(viewModel.presets, id: \.self) { preset in
                                Button(action: {
                                    viewModel.addWaterEntry(amount: preset)
                                }) {
                                    HStack {
                                        Image(systemName: "drop.fill")
                                            .font(.system(size: 16))
                                        
                                        Text("\(String(format: "%.0f", preset)) oz")
                                            .font(.system(size: 16, weight: .semibold))
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
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
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WaterTrackingViewModel())
}
