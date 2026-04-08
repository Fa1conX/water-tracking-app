//
//  LogsView.swift
//  BasicWaterTracker
//
//  View for displaying water intake logs by date
//

import SwiftUI

struct LogsView: View {
    @EnvironmentObject var viewModel: WaterTrackingViewModel
    @State private var selectedDate: Date = Date()
    @Environment(\.colorScheme) var colorScheme
    
    var selectedDateEntries: [WaterEntry] {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        return viewModel.entries
            .filter { Calendar.current.startOfDay(for: $0.date) == startOfDay }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    var selectedDateTotal: Double {
        selectedDateEntries.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 0) {
                // Header with date navigation
                HStack {
                    Button(action: { selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                    }
                    
                    VStack(spacing: 4) {
                        Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 18, weight: .semibold))
                        Text("\(String(format: "%.1f", selectedDateTotal)) oz")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                        if tomorrow <= Date() {
                            selectedDate = tomorrow
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .padding(.top, 8)
                
                // Logs list
                if selectedDateEntries.isEmpty {
                    VStack {
                        Spacer()
                        Text("No entries for this day")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(AppBackgroundView())
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(selectedDateEntries) { entry in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(String(format: "%.1f", entry.amount)) oz")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                        Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(colorScheme == .dark ? .gray : .gray)
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
                                .background(colorScheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                    .background(AppBackgroundView())
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    LogsView()
        .environmentObject(WaterTrackingViewModel())
}
