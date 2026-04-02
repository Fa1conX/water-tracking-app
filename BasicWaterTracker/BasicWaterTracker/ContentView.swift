//
//  ContentView.swift
//  BasicWaterTracker
//
//  Main view showing water intake tracking
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: WaterTrackingViewModel
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            NavigationView {
                VStack(spacing: 20) {
                    // Daily Total Section
                    VStack(spacing: 10) {
                        Text("Today's Water Intake")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text(String(format: "%.0f", viewModel.getTdayTotal()))
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.blue)
                                Text("ml")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ProgressView(value: min(viewModel.getTdayTotal() / 2000, 1.0))
                                Text("Goal: 2000 ml")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Quick Add Buttons
                    VStack(spacing: 10) {
                        Text("Quick Add")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 10) {
                            QuickAddButton(amount: 250, label: "250ml")
                            QuickAddButton(amount: 500, label: "500ml")
                            QuickAddButton(amount: 750, label: "750ml")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Today's Entries
                    VStack(spacing: 10) {
                        Text("Today's Entries")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if viewModel.getTodayEntries().isEmpty {
                            Text("No entries yet. Add your first water intake!")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            List {
                                ForEach(viewModel.getTodayEntries()) { entry in
                                    HStack {
                                        Image(systemName: "drop.fill")
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading) {
                                            Text("\(Int(entry.amount)) ml")
                                                .font(.body)
                                            Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            viewModel.removeEntry(entry)
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .navigationTitle("Water Tracker")
            }
        }
    }
}

// MARK: - Quick Add Button Component
struct QuickAddButton: View {
    @EnvironmentObject var viewModel: WaterTrackingViewModel
    
    let amount: Double
    let label: String
    
    var body: some View {
        Button(action: {
            viewModel.addWaterEntry(amount: amount)
        }) {
            VStack {
                Image(systemName: "drop.fill")
                    .font(.title3)
                Text(label)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WaterTrackingViewModel())
}
