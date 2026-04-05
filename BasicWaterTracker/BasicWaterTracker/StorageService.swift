//
//  StorageService.swift
//  BasicWaterTracker
//
//  Handles data persistence using UserDefaults
//

import Foundation

class StorageService {
    static let shared = StorageService()
    
    private let storageKey = "waterEntries"
    
    func saveEntries(_ entries: [WaterEntry]) {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func loadEntries() -> [WaterEntry] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        
        if let decoded = try? JSONDecoder().decode([WaterEntry].self, from: data) {
            return decoded
        }
        return []
    }
    
    func savePresets(_ presets: [Double]) {
        UserDefaults.standard.set(presets, forKey: "waterPresets")
    }
    
    func loadPresets() -> [Double] {
        let defaults = UserDefaults.standard.array(forKey: "waterPresets") as? [Double]
        return defaults ?? [8, 16, 24]  // Default presets in oz
    }
    
    func saveDailyGoal(_ goal: Double) {
        UserDefaults.standard.set(goal, forKey: "waterDailyGoal")
    }
    
    func loadDailyGoal() -> Double {
        let saved = UserDefaults.standard.double(forKey: "waterDailyGoal")
        return saved > 0 ? saved : 64  // Default daily goal in oz
    }
    
    // MARK: - Notification Settings
    
    func saveNotificationsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "notificationsEnabled")
    }
    
    func loadNotificationsEnabled() -> Bool {
        UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }
    
    func saveNotificationMode(_ mode: String) {
        UserDefaults.standard.set(mode, forKey: "notificationMode")
    }
    
    func loadNotificationMode() -> String {
        UserDefaults.standard.string(forKey: "notificationMode") ?? "disabled"
    }
    
    func saveIntervalHours(_ hours: Double) {
        UserDefaults.standard.set(hours, forKey: "notificationIntervalHours")
    }
    
    func loadIntervalHours() -> Double {
        let saved = UserDefaults.standard.double(forKey: "notificationIntervalHours")
        return saved > 0 ? saved : 2.0  // Default 2 hours
    }
    
    func saveSpecificTimes(_ times: [Date]) {
        if let encoded = try? JSONEncoder().encode(times) {
            UserDefaults.standard.set(encoded, forKey: "notificationSpecificTimes")
        }
    }
    
    func loadSpecificTimes() -> [Date] {
        guard let data = UserDefaults.standard.data(forKey: "notificationSpecificTimes") else {
            // Default times: 9am, 12pm, 3pm, 6pm
            let calendar = Calendar.current
            return [
                calendar.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
                calendar.date(from: DateComponents(hour: 12, minute: 0)) ?? Date(),
                calendar.date(from: DateComponents(hour: 15, minute: 0)) ?? Date(),
                calendar.date(from: DateComponents(hour: 18, minute: 0)) ?? Date(),
            ]
        }
        
        if let decoded = try? JSONDecoder().decode([Date].self, from: data) {
            return decoded
        }
        return []
    }

    func saveUrgentNoLogReminderEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "urgentNoLogReminderEnabled")
    }

    func loadUrgentNoLogReminderEnabled() -> Bool {
        if UserDefaults.standard.object(forKey: "urgentNoLogReminderEnabled") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "urgentNoLogReminderEnabled")
    }

    func saveUrgentNoLogReminderTime(_ time: Date) {
        UserDefaults.standard.set(time.timeIntervalSince1970, forKey: "urgentNoLogReminderTime")
    }

    func loadUrgentNoLogReminderTime() -> Date {
        let saved = UserDefaults.standard.double(forKey: "urgentNoLogReminderTime")
        if saved > 0 {
            return Date(timeIntervalSince1970: saved)
        }

        return Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date()
    }
}
