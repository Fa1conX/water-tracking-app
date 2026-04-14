//
//  WaterTrackingViewModel.swift
//  BasicWaterTracker
//
//  ViewModel for managing water intake tracking logic
//

import Foundation
import Combine

struct DailyIntakePoint: Identifiable {
    let date: Date
    let total: Double

    var id: Date { date }
}

class WaterTrackingViewModel: ObservableObject {
    @Published var entries: [WaterEntry] = []
    @Published var selectedDate: Date = Date()
    @Published var presets: [Double] = [8, 16, 24]  // oz values
    @Published var dailyGoal: Double = 64  // oz
    @Published var isLoaded: Bool = false
    
    // Notification settings
    @Published var notificationsEnabled: Bool = false
    @Published var notificationMode: String = "disabled"  // "disabled", "interval", or "specific"
    @Published var intervalHours: Double = 2.0
    @Published var specificTimes: [Date] = []
    @Published var urgentNoLogReminderEnabled: Bool = true
    @Published var urgentNoLogReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date()
    
    private let storageService = StorageService.shared
    private let notificationManager = NotificationManager.shared
    
    init() {
        loadEntries()
        loadPresets()
        loadDailyGoal()
        loadNotificationSettings()
        DispatchQueue.main.async {
            self.isLoaded = true
        }
    }
    
    // MARK: - Public Methods
    
    func addWaterEntry(amount: Double) {
        let entry = WaterEntry(date: Date(), amount: amount)
        entries.append(entry)
        saveEntries()
        syncUrgentNoLogReminder()
    }
    
    func removeEntry(_ entry: WaterEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
        syncUrgentNoLogReminder()
    }
    
    func removeLastEntry() {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastIndex = entries.lastIndex(where: { Calendar.current.startOfDay(for: $0.date) == today }) {
            entries.remove(at: lastIndex)
            saveEntries()
            syncUrgentNoLogReminder()
        }
    }
    
    func getTdayTotal() -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        return entries
            .filter { Calendar.current.startOfDay(for: $0.date) == today }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getTodayEntries() -> [WaterEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return entries
            .filter { Calendar.current.startOfDay(for: $0.date) == today }
            .sorted { $0.timestamp > $1.timestamp }
    }

    func getLast14DaysIntake() -> [DailyIntakePoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<14).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -(13 - offset), to: today) else {
                return nil
            }

            let total = entries
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.amount }

            return DailyIntakePoint(date: date, total: total)
        }
    }

    func getTrailing7DayAverageExcludingToday() -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let totals = (1...7).compactMap { daysBack -> Double? in
            guard let day = calendar.date(byAdding: .day, value: -daysBack, to: today) else {
                return nil
            }
            return totalIntake(on: day)
        }

        guard !totals.isEmpty else { return 0 }
        return totals.reduce(0, +) / Double(totals.count)
    }

    func getGoalStreakExcludingToday() -> Int {
        guard dailyGoal > 0 else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var daysBack = 1

        while let day = calendar.date(byAdding: .day, value: -daysBack, to: today) {
            if totalIntake(on: day) >= dailyGoal {
                streak += 1
                daysBack += 1
            } else {
                break
            }
        }

        return streak
    }
    
    // MARK: - Grade & GPA Calculation
    
    func getTodayGrade() -> String {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let todayEntries = entries.filter { calendar.startOfDay(for: $0.date) == today }
        let currentHour = calendar.component(.hour, from: now)
        
        // Show "--" until either 1 entry is logged or 6 PM (18:00)
        if todayEntries.isEmpty && currentHour < 18 {
            return "--"
        }
        
        let todayTotal = getTdayTotal()
        let percentage = (todayTotal / dailyGoal) * 100
        return percentageToGrade(percentage)
    }
    
    func getSevenDayGPA() -> Double {
        guard dailyGoal > 0 else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let currentHour = calendar.component(.hour, from: now)
        
        // Before 6 PM: last 7 complete days (days 1-7 back)
        // After 6 PM: rolling 7 days including today (days 0-6 back)
        let daysBackRange = currentHour >= 18 ? (0...6) : (1...7)
        
        var grades: [Double] = []
        
        for daysBack in daysBackRange {
            guard let day = calendar.date(byAdding: .day, value: -daysBack, to: today) else {
                continue
            }
            
            let total = totalIntake(on: day)
            let percentage = (total / dailyGoal) * 100
            let grade = percentageToGrade(percentage)
            let gpaValue = gradeToGPA(grade)
            grades.append(gpaValue)
        }
        
        guard !grades.isEmpty else { return 0 }
        return grades.reduce(0, +) / Double(grades.count)
    }
    
    private func percentageToGrade(_ percentage: Double) -> String {
        let p = max(0, min(percentage, 999)) // Clamp to prevent out of range
        
        switch p {
        case let p where p > 100:
            return "A+"
        case 93...100:
            return "A"
        case 90..<93:
            return "A-"
        case 87..<90:
            return "B+"
        case 83..<87:
            return "B"
        case 80..<83:
            return "B-"
        case 77..<80:
            return "C+"
        case 73..<77:
            return "C"
        case 70..<73:
            return "C-"
        case 67..<70:
            return "D+"
        case 63..<67:
            return "D"
        case 60..<63:
            return "D-"
        default:
            return "F"
        }
    }
    
    private func gradeToGPA(_ grade: String) -> Double {
        switch grade {
        case "A+":
            return 4.5
        case "A":
            return 4.0
        case "A-":
            return 3.7
        case "B+":
            return 3.3
        case "B":
            return 3.0
        case "B-":
            return 2.7
        case "C+":
            return 2.3
        case "C":
            return 2.0
        case "C-":
            return 1.7
        case "D+":
            return 1.3
        case "D":
            return 1.0
        case "D-":
            return 0.7
        default: // F or "--"
            return 0.0
        }
    }
    
    // MARK: - Private Methods
    
    private func loadEntries() {
        entries = storageService.loadEntries()
    }
    
    private func saveEntries() {
        storageService.saveEntries(entries)
    }
    
    private func loadPresets() {
        presets = storageService.loadPresets()
    }

    private func totalIntake(on date: Date) -> Double {
        let calendar = Calendar.current
        return entries
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.amount }
    }
    
    func updatePresets(_ newPresets: [Double]) {
        presets = newPresets
        storageService.savePresets(newPresets)
    }
    
    func updateDailyGoal(_ newGoal: Double) {
        dailyGoal = newGoal
        storageService.saveDailyGoal(newGoal)
    }
    
    private func loadDailyGoal() {
        dailyGoal = storageService.loadDailyGoal()
    }
    
    // MARK: - Notification Methods
    
    private func loadNotificationSettings() {
        notificationsEnabled = storageService.loadNotificationsEnabled()
        notificationMode = storageService.loadNotificationMode()
        intervalHours = storageService.loadIntervalHours()
        specificTimes = storageService.loadSpecificTimes()
        urgentNoLogReminderEnabled = storageService.loadUrgentNoLogReminderEnabled()
        urgentNoLogReminderTime = storageService.loadUrgentNoLogReminderTime()
        syncUrgentNoLogReminder()
    }
    
    func enableIntervalReminders(hours: Double) {
        intervalHours = hours
        notificationMode = "interval"
        notificationsEnabled = true
        
        storageService.saveNotificationsEnabled(true)
        storageService.saveNotificationMode("interval")
        storageService.saveIntervalHours(hours)
        
        notificationManager.scheduleReminders(mode: .interval(hours: hours))
        syncUrgentNoLogReminder()
    }
    
    func enableSpecificTimeReminders(times: [Date]) {
        specificTimes = times
        notificationMode = "specific"
        notificationsEnabled = true
        
        storageService.saveNotificationsEnabled(true)
        storageService.saveNotificationMode("specific")
        storageService.saveSpecificTimes(times)
        
        notificationManager.scheduleReminders(mode: .specific(times: times))
        syncUrgentNoLogReminder()
    }
    
    func disableReminders() {
        notificationsEnabled = false
        notificationMode = "disabled"
        
        storageService.saveNotificationsEnabled(false)
        storageService.saveNotificationMode("disabled")
        
        notificationManager.disableReminders()
        syncUrgentNoLogReminder()
    }

    func updateUrgentNoLogReminder(enabled: Bool, cutoffTime: Date) {
        urgentNoLogReminderEnabled = enabled
        urgentNoLogReminderTime = cutoffTime

        storageService.saveUrgentNoLogReminderEnabled(enabled)
        storageService.saveUrgentNoLogReminderTime(cutoffTime)

        syncUrgentNoLogReminder()
    }

    private func syncUrgentNoLogReminder() {
        guard notificationsEnabled && urgentNoLogReminderEnabled else {
            notificationManager.disableUrgentNoLogReminder()
            return
        }

        let hasLoggedToday = getTdayTotal() > 0
        notificationManager.scheduleUrgentNoLogReminder(
            cutoffTime: urgentNoLogReminderTime,
            hasLoggedToday: hasLoggedToday
        )
    }
}
