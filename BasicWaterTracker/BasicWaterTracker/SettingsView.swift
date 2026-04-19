//
//  SettingsView.swift
//  BasicWaterTracker
//
//  Settings and configuration view
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: WaterTrackingViewModel
    @Environment(\.dismiss) var dismiss
    
    // Water settings
    @State private var preset1: String = ""
    @State private var preset2: String = ""
    @State private var preset3: String = ""
    @State private var dailyGoalInput: String = ""
    
    // Notification settings
    @State private var notificationsEnabled: Bool = false
    @State private var notificationMode: String = "disabled"  // "interval" or "specific"
    @State private var intervalHours: Double = 2.0
    @State private var specificTimes: [Date] = []
    @State private var urgentNoLogReminderEnabled: Bool = true
    @State private var urgentNoLogReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date()
    
    // Display settings
    @State private var showGradeMetrics: Bool = true
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Goal (oz)")) {
                    TextField("Daily Goal", text: $dailyGoalInput)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Quick Add Presets (oz)")) {
                    TextField("Preset 1", text: $preset1)
                        .keyboardType(.decimalPad)
                    TextField("Preset 2", text: $preset2)
                        .keyboardType(.decimalPad)
                    TextField("Preset 3", text: $preset3)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Reset")) {
                    Button(action: resetPresets) {
                        Text("Reset to Default")
                            .foregroundColor(.orange)
                    }
                }
                
                // MARK: - Notification Settings
                Section(header: Text("Reminders")) {
                    Toggle("Enable Reminders", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) {
                            if notificationsEnabled && notificationMode == "disabled" {
                                notificationMode = "interval"
                            } else if !notificationsEnabled {
                                notificationMode = "disabled"
                            }
                        }
                }
                
                if notificationsEnabled {
                    Section(header: Text("Reminder Type")) {
                        Picker("Reminder Type", selection: $notificationMode) {
                            Text("Fixed Interval").tag("interval")
                            Text("Specific Times").tag("specific")
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    if notificationMode == "interval" {
                        Section(header: Text("Remind me every")) {
                            HStack {
                                Stepper(
                                    value: $intervalHours,
                                    in: 0.5...12,
                                    step: 0.5
                                ) {
                                    Text("\(String(format: "%.1f", intervalHours)) hours")
                                }
                            }
                        }
                    }
                    
                    if notificationMode == "specific" {
                        Section(header: Text("Reminder Times")) {
                            ForEach(0..<specificTimes.count, id: \.self) { index in
                                HStack {
                                    Text("Reminder \(index + 1)")
                                    Spacer()
                                    DatePicker(
                                        "",
                                        selection: $specificTimes[index],
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                }
                            }
                            
                            Button(action: addReminderTime) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Reminder")
                                }
                            }
                            .foregroundColor(.blue)
                            
                            if specificTimes.count > 0 {
                                Button(action: removeLastReminderTime) {
                                    HStack {
                                        Image(systemName: "minus.circle.fill")
                                        Text("Remove Last Reminder")
                                    }
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }

                    Section(header: Text("Urgent No-Log Alert")) {
                        Toggle("Alert if no logs by time", isOn: $urgentNoLogReminderEnabled)

                        if urgentNoLogReminderEnabled {
                            DatePicker(
                                "Alert Time",
                                selection: $urgentNoLogReminderTime,
                                displayedComponents: .hourAndMinute
                            )
                        }
                    }
                    
                    Section(header: Text("Display")) {
                        Toggle("Show Grade Metrics", isOn: $showGradeMetrics)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentPresets()
                loadCurrentDailyGoal()
                loadCurrentNotificationSettings()
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Water Settings Methods
    
    private func loadCurrentPresets() {
        preset1 = String(viewModel.presets[0])
        preset2 = String(viewModel.presets[1])
        preset3 = String(viewModel.presets[2])
    }
    
    private func loadCurrentDailyGoal() {
        dailyGoalInput = String(Int(viewModel.dailyGoal))
    }
    
    private func resetPresets() {
        viewModel.updatePresets([8, 16, 24])
        viewModel.updateDailyGoal(64)
        loadCurrentPresets()
        loadCurrentDailyGoal()
        alertMessage = "Settings reset to default!"
        showAlert = true
    }
    
    // MARK: - Notification Settings Methods
    
    private func loadCurrentNotificationSettings() {
        notificationsEnabled = viewModel.notificationsEnabled
        notificationMode = viewModel.notificationMode
        intervalHours = viewModel.intervalHours
        urgentNoLogReminderEnabled = viewModel.urgentNoLogReminderEnabled
        urgentNoLogReminderTime = viewModel.urgentNoLogReminderTime
        specificTimes = viewModel.specificTimes.isEmpty ? [
            Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
            Calendar.current.date(from: DateComponents(hour: 12, minute: 0)) ?? Date(),
            Calendar.current.date(from: DateComponents(hour: 15, minute: 0)) ?? Date(),
            Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date(),
        ] : viewModel.specificTimes
        
        showGradeMetrics = viewModel.showGradeMetrics
    }
    
    private func addReminderTime() {
        if let lastTime = specificTimes.last {
            let calendar = Calendar.current
            let lastComponents = calendar.dateComponents([.hour, .minute], from: lastTime)
            let lastHour = lastComponents.hour ?? 0
            let newHour = (lastHour + 3) % 24
            
            if let newTime = calendar.date(from: DateComponents(hour: newHour, minute: 0)) {
                specificTimes.append(newTime)
            }
        }
    }
    
    private func removeLastReminderTime() {
        if !specificTimes.isEmpty {
            specificTimes.removeLast()
        }
    }
    
    private func saveSettings() {
        // Save water settings
        guard let p1 = Double(preset1), p1 > 0,
              let p2 = Double(preset2), p2 > 0,
              let p3 = Double(preset3), p3 > 0 else {
            alertMessage = "Please enter valid positive numbers for all presets"
            showAlert = true
            return
        }
        
        guard let goal = Double(dailyGoalInput), goal > 0 else {
            alertMessage = "Please enter a valid positive number for daily goal"
            showAlert = true
            return
        }
        
        viewModel.updatePresets([p1, p2, p3])
        viewModel.updateDailyGoal(goal)
        
        // Save notification settings
        if notificationsEnabled {
            if notificationMode == "interval" {
                viewModel.enableIntervalReminders(hours: intervalHours)
            } else if notificationMode == "specific" {
                viewModel.enableSpecificTimeReminders(times: specificTimes)
            }
        } else {
            viewModel.disableReminders()
        }

        viewModel.updateUrgentNoLogReminder(
            enabled: urgentNoLogReminderEnabled,
            cutoffTime: urgentNoLogReminderTime
        )
        
        viewModel.setShowGradeMetrics(showGradeMetrics)
    }
}

#Preview {
    SettingsView()
        .environmentObject(WaterTrackingViewModel())
}
