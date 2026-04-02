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
    
    @State private var preset1: String = ""
    @State private var preset2: String = ""
    @State private var preset3: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Quick Add Presets (oz)")) {
                    TextField("Preset 1", text: $preset1)
                        .keyboardType(.decimalPad)
                    TextField("Preset 2", text: $preset2)
                        .keyboardType(.decimalPad)
                    TextField("Preset 3", text: $preset3)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button(action: savePresets) {
                        Text("Save Presets")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: resetPresets) {
                        Text("Reset to Default")
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentPresets()
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func loadCurrentPresets() {
        preset1 = String(viewModel.presets[0])
        preset2 = String(viewModel.presets[1])
        preset3 = String(viewModel.presets[2])
    }
    
    private func savePresets() {
        guard let p1 = Double(preset1), p1 > 0,
              let p2 = Double(preset2), p2 > 0,
              let p3 = Double(preset3), p3 > 0 else {
            alertMessage = "Please enter valid positive numbers for all presets"
            showAlert = true
            return
        }
        
        viewModel.updatePresets([p1, p2, p3])
        alertMessage = "Presets saved successfully!"
        showAlert = true
    }
    
    private func resetPresets() {
        viewModel.updatePresets([8, 16, 24])
        loadCurrentPresets()
        alertMessage = "Presets reset to default!"
        showAlert = true
    }
}

#Preview {
    SettingsView()
        .environmentObject(WaterTrackingViewModel())
}
