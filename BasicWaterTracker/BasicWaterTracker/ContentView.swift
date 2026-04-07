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
    @State private var showLogs = false
    
    var todayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Calendar.current.startOfDay(for: Date()))
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with settings
                HStack {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("7-Day Avg")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.1f", viewModel.getTrailing7DayAverageExcludingToday())) oz")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Streak")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("\(viewModel.getGoalStreakExcludingToday()) days")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .padding(.top, 8)
                
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
                            
                            // Circular progress indicator - tap to view logs
                            Button(action: { showLogs = true }) {
                                CircularWaterProgress(
                                    currentAmount: viewModel.getTdayTotal(),
                                    dailyGoal: viewModel.dailyGoal
                                )
                                .frame(maxWidth: 200)
                            }
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

                        Button(action: { showLogs = true }) {
                            TwoWeekIntakeChart(
                                points: viewModel.getLast14DaysIntake(),
                                dailyGoal: viewModel.dailyGoal
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.appBackground)
                    .id(todayDate)
                }
                .background(Color.appBackground)
            }
            .background(Color.appBackground)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showLogs) {
            LogsView()
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TwoWeekIntakeChart: View {
    let points: [DailyIntakePoint]
    let dailyGoal: Double
    private let chartHeight: CGFloat = 110
    private let barSpacing: CGFloat = 6

    private var maxValue: Double {
        max(points.map(\.total).max() ?? 0, dailyGoal, 1)
    }

    private var goalLineOffset: CGFloat {
        let ratio = CGFloat(min(max(dailyGoal / maxValue, 0), 1))
        return -(ratio * chartHeight)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 14 Days")
                .font(.system(size: 16, weight: .semibold))

            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.35))
                    .frame(height: 1)
                    .offset(y: goalLineOffset)

                HStack(alignment: .bottom, spacing: barSpacing) {
                    ForEach(points) { point in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(point.total >= dailyGoal ? Color.green : Color.blue)
                            .frame(height: max(6, CGFloat(point.total / maxValue) * chartHeight))
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: chartHeight, alignment: .bottom)

            HStack(alignment: .center, spacing: barSpacing) {
                ForEach(points) { point in
                    Text(point.date.formatted(.dateTime.weekday(.narrow)))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            HStack(spacing: 14) {
                HStack(spacing: 6) {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("Over goal")
                }

                HStack(spacing: 6) {
                    Circle().fill(Color.blue).frame(width: 8, height: 8)
                    Text("Below goal")
                }
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
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
