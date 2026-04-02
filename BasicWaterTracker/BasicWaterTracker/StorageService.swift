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
}
