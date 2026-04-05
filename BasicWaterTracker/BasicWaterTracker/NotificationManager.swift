//
//  NotificationManager.swift
//  BasicWaterTracker
//
//  Handles local notifications for water intake reminders
//

import Foundation
import Combine
import UIKit
import UserNotifications

enum NotificationMode {
    case disabled
    case interval(hours: Double)  // e.g., every 2 hours
    case specific(times: [Date])  // specific times (store just hour/minute)
}

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notificationsEnabled = false
    @Published var notificationMode: NotificationMode = .disabled
    @Published var intervalHours: Double = 2.0
    @Published var specificTimes: [Date] = [
        Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        Calendar.current.date(from: DateComponents(hour: 12, minute: 0)) ?? Date(),
        Calendar.current.date(from: DateComponents(hour: 15, minute: 0)) ?? Date(),
        Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date(),
    ]
    
    private init() {}
    
    // MARK: - Public Methods
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleReminders(mode: NotificationMode) {
        // Cancel all existing notifications
        let intervalIdentifiers = (0..<5).map { "water_reminder_\($0)" }
        let specificIdentifiers = (0..<10).map { "water_reminder_specific_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: intervalIdentifiers + specificIdentifiers
        )
        
        self.notificationMode = mode
        
        switch mode {
        case .disabled:
            self.notificationsEnabled = false
            
        case .interval(let hours):
            self.notificationsEnabled = true
            scheduleIntervalReminders(hours: hours)
            
        case .specific(let times):
            self.notificationsEnabled = true
            scheduleSpecificTimeReminders(times: times)
        }
    }
    
    func disableReminders() {
        let intervalIdentifiers = (0..<5).map { "water_reminder_\($0)" }
        let specificIdentifiers = (0..<10).map { "water_reminder_specific_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: intervalIdentifiers + specificIdentifiers
        )
        self.notificationsEnabled = false
        self.notificationMode = .disabled
    }
    
    // MARK: - Private Methods
    
    private func scheduleIntervalReminders(hours: Double) {
        let reminderMessages = [
            "Time to hydrate! 💧",
            "Don't forget to drink water! 💧",
            "Stay hydrated throughout the day 💧",
            "Keep up the water intake! 💧",
            "Refill your glass! 💧"
        ]
        
        // Schedule 5 reminders throughout the day (starting at 8 AM)
        let startHour = 8
        for i in 0..<5 {
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: DateComponents(
                    hour: startHour + Int(Double(i) * hours),
                    minute: 0
                ),
                repeats: true
            )
            
            let content = UNMutableNotificationContent()
            content.title = "Water Reminder"
            content.body = reminderMessages[i % reminderMessages.count]
            content.sound = .default
            content.badge = NSNumber(value: 1)
            
            let request = UNNotificationRequest(
                identifier: "water_reminder_\(i)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling interval reminder: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func scheduleSpecificTimeReminders(times: [Date]) {
        let reminderMessages = [
            "Time to hydrate! 💧",
            "Don't forget to drink water! 💧",
            "Stay hydrated throughout the day 💧",
            "Keep up the water intake! 💧",
            "Refill your glass! 💧"
        ]
        
        for (index, time) in times.enumerated() {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: time)
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: DateComponents(
                    hour: components.hour,
                    minute: components.minute
                ),
                repeats: true
            )
            
            let content = UNMutableNotificationContent()
            content.title = "Water Reminder"
            content.body = reminderMessages[index % reminderMessages.count]
            content.sound = .default
            content.badge = NSNumber(value: 1)
            
            let request = UNNotificationRequest(
                identifier: "water_reminder_specific_\(index)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling specific time reminder: \(error.localizedDescription)")
                }
            }
        }
    }
}
