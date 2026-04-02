//
//  WaterEntry.swift
//  BasicWaterTracker
//
//  Data model for a single water intake entry
//

import Foundation

struct WaterEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Double  // in ounces
    let timestamp: Date
    
    init(date: Date, amount: Double) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.timestamp = Date()
    }
}

// MARK: - Daily Water Summary
struct DailyWaterSummary {
    let date: Date
    let totalIntake: Double  // in milliliters
    let entries: [WaterEntry]
    
    var formattedTotal: String {
        return String(format: "%.0f ml", totalIntake)
    }
}
