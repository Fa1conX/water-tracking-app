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
    
    private let storageService = StorageService.shared
    
    init() {
        loadEntries()
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
}
