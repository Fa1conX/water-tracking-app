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

    var todayTotal: Double {
        viewModel.getTdayTotal()
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()

            
            VStack(spacing: 0) {
                // Header with settings
                HStack {
                    HStack(spacing: 10) {
                        if viewModel.showGradeMetrics {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("GPA")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.2f", viewModel.getSevenDayGPA()))")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Today")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text(viewModel.getTodayGrade())
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)

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
                        }

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
                                if todayTotal > 0 {
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
                                    currentAmount: todayTotal,
                                    dailyGoal: viewModel.dailyGoal
                                )
                                .frame(maxWidth: 200)
                                .id(todayDate)
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

                        TwoWeekIntakeChart(
                            points: viewModel.getLast14DaysIntake(),
                            dailyGoal: viewModel.dailyGoal,
                            onTitleTap: { showLogs = true }
                        )
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(AppBackgroundView())
                    .id(todayDate)
                }
                .background(AppBackgroundView())
            }
            .background(AppBackgroundView())
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showLogs) {
            LogsView()
        }
        .onChange(of: todayDate) {
            // Force refresh when date changes
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
    let onTitleTap: () -> Void
    @State private var selectedPointID: Date?
    @State private var hidePopupWorkItem: DispatchWorkItem?
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
            Button(action: onTitleTap) {
                HStack(spacing: 6) {
                    Text("Last 14 Days")
                        .font(.system(size: 16, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.primary)
            }
            .buttonStyle(.plain)

            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.35))
                    .frame(height: 1)
                    .offset(y: goalLineOffset)

                HStack(alignment: .bottom, spacing: barSpacing) {
                    ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(point.total >= dailyGoal ? Color.green : Color.blue)
                            .frame(height: max(6, CGFloat(point.total / maxValue) * chartHeight))
                            .overlay(alignment: .top) {
                                if selectedPointID == point.id {
                                    BarValuePopup(
                                        text: "\(Int(point.total.rounded())) oz",
                                        arrowOffset: -popupXOffset(for: index)
                                    )
                                    .offset(x: popupXOffset(for: index), y: -34)
                                    .transition(.opacity)
                                }
                            }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedPointID == point.id {
                                hideSelectedPopup()
                            } else {
                                showPopup(for: point.id)
                            }
                        }
                    }
                }
            }
            .frame(height: chartHeight, alignment: .bottom)
            .onDisappear {
                hidePopupWorkItem?.cancel()
                hidePopupWorkItem = nil
            }

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

    private func popupXOffset(for index: Int) -> CGFloat {
        if index == 0 { return 24 }
        if index == 1 { return 10 }
        if index == points.count - 2 { return -10 }
        if index == points.count - 1 { return -24 }
        return 0
    }

    private func showPopup(for id: Date) {
        hidePopupWorkItem?.cancel()

        withAnimation(.easeInOut(duration: 0.2)) {
            selectedPointID = id
        }

        let workItem = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPointID = nil
            }
        }

        hidePopupWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: workItem)
    }

    private func hideSelectedPopup() {
        hidePopupWorkItem?.cancel()
        hidePopupWorkItem = nil

        withAnimation(.easeInOut(duration: 0.2)) {
            selectedPointID = nil
        }
    }
}

private struct BarValuePopup: View {
    let text: String
    let arrowOffset: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)
                .frame(minWidth: 60)
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
                .background(Color(.systemBackground).opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(Color.secondary.opacity(0.35), lineWidth: 1)
                )
                .cornerRadius(9)

            TrianglePointer()
                .fill(Color(.systemBackground).opacity(0.96))
                .frame(width: 12, height: 8)
                .overlay(
                    TrianglePointer()
                        .stroke(Color.secondary.opacity(0.35), lineWidth: 1)
                )
                .offset(x: arrowOffset)
        }
    }
}

private struct TrianglePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
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
