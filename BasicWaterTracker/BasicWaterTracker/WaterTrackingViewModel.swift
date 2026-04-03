//
//  WaterTrackingViewModel.swift
//  BasicWaterTracker
//
//  ViewModel for managing water intake tracking logic
//

import Foundation
import Combine

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
