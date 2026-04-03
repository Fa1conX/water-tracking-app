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
    
    private let storageService = StorageService.shared
    
    init() {
        loadEntries()
        loadPresets()
        loadDailyGoal()
        DispatchQueue.main.async {
            self.isLoaded = true
        }
    }
    
    // MARK: - Public Methods
    
    func addWaterEntry(amount: Double) {
        let entry = WaterEntry(date: Date(), amount: amount)
        entries.append(entry)
        saveEntries()
    }
    
    func removeEntry(_ entry: WaterEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    func removeLastEntry() {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastIndex = entries.lastIndex(where: { Calendar.current.startOfDay(for: $0.date) == today }) {
            entries.remove(at: lastIndex)
            saveEntries()
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
}
