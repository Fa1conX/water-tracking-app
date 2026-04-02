# Water Tracker iOS App

A simple, elegant iOS app for tracking daily water intake built with SwiftUI.

## 📋 Overview

Water Tracker helps you stay hydrated by making it easy to log your water consumption throughout the day. With quick-add buttons, a visual progress indicator, and entry history, you can effortlessly monitor your daily hydration goals.

## ✨ Features

- 💧 **Quick Add Buttons** - Log water intake in seconds with preset amounts (250ml, 500ml, 750ml)
- 📊 **Daily Progress Tracking** - Visual progress bar showing how close you are to your 2000ml daily goal
- 📝 **Entry History** - View all water entries for the current day with timestamps
- 🗑️ **Swipe to Delete** - Remove entries with a simple swipe gesture
- 💾 **Local Storage** - All data persists locally on your device using UserDefaults
- 🎨 **Clean UI** - Intuitive, beginner-friendly interface built with SwiftUI
- 📱 **iPad Compatible** - Works seamlessly on both iPhone and iPad

## 🎯 Technical Stack

- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Architecture:** MVVM (Model-View-ViewModel)
- **Data Persistence:** UserDefaults
- **Minimum OS:** iOS 15+
- **Device Support:** iPhone and iPad

## 📁 Project Structure

```
BasicWaterTracker/
├── BasicWaterTracker/
│   ├── BasicWaterTrackerApp.swift      # App entry point
│   ├── ContentView.swift               # Main UI view
│   ├── WaterEntry.swift                # Data model
│   ├── WaterTrackingViewModel.swift    # State management & logic
│   ├── StorageService.swift            # Data persistence layer
│   ├── Assets.xcassets/                # Images and app icons
│   ├── LaunchScreen.storyboard         # Launch screen
│   └── Preview Content/                # SwiftUI previews
├── BasicWaterTrackerTests/             # Unit tests
├── BasicWaterTrackerUITests/           # UI tests
└── BasicWaterTracker.xcodeproj/        # Xcode project configuration
```

## 🚀 Getting Started

### Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later
- iOS 15.0 or later (target device/simulator)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/water-tracker.git
   cd water-tracker
   ```

2. **Open in Xcode**
   ```bash
   open BasicWaterTracker.xcodeproj
   ```

3. **Select a simulator or connected device**
   - Choose iPhone or iPad from the device selector in Xcode

4. **Build and run**
   - Press `Cmd+R` or click the Play button in Xcode

## 💻 Usage

### Logging Water Intake

1. **Quick Add:** Tap any of the preset buttons (250ml, 500ml, 750ml) to instantly log water
2. **View Progress:** See your daily total and progress toward the 2000ml goal at the top
3. **View History:** Scroll through "Today's Entries" to see all logged water intakes with timestamps
4. **Delete Entry:** Swipe left on any entry and tap the trash icon to remove it

### Daily Goal

- Default goal: **2000ml per day**
- The progress bar fills as you log water
- Progress resets at midnight each day

## 🏗️ Architecture

This app follows the **MVVM (Model-View-ViewModel)** pattern:

- **Models** (`WaterEntry`, `DailyWaterSummary`)
  - Define data structures for water entries and daily summaries
  - All models are `Codable` for JSON serialization

- **Views** (`ContentView`, `QuickAddButton`)
  - SwiftUI views that display data and handle user interactions
  - Observes ViewModel for state changes

- **ViewModels** (`WaterTrackingViewModel`)
  - Manages app state with `@Published` properties
  - Handles business logic (adding/removing entries, calculations)
  - Interfaces with StorageService for persistence

- **Services** (`StorageService`)
  - Handles all data persistence
  - Uses UserDefaults for simple local storage
  - Provides load/save operations

## 🧪 Testing

### Building Tests

The project includes test targets for both unit and UI tests:

**Unit Tests:**
```bash
Cmd+U  # Run all tests in Xcode
```

**UI Tests:**
```bash
Cmd+U  # Runs as part of full test suite
```

## 🔧 Build & Development

### Building for Simulator

```bash
# Debug build (default)
Cmd+B  # Build for currently selected simulator
```

### Building for Device

1. Connect an iOS device
2. Select device from Xcode's device selector
3. Press `Cmd+B` to build

### Build Settings

- **Bundle Identifier:** `com.basicwatertracker.app`
- **Minimum Deployment Target:** iOS 15.0
- **Supported Orientations:** Portrait, Landscape Left, Landscape Right

## 📈 Future Enhancements

- [ ] Core Data migration for better performance with large datasets
- [ ] Daily notifications/reminders to drink water
- [ ] Statistics and history view (weekly/monthly tracking)
- [ ] Custom daily goal settings
- [ ] Dark mode support
- [ ] Water intake goals by body weight
- [ ] Export data to CSV
- [ ] Cloud synchronization (iCloud)
- [ ] Graphical charts and analytics
- [ ] Social sharing features

## 🐛 Known Issues

None currently reported. Please open an issue if you find any bugs.

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add YourFeature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Karsten H**

## 💬 Support

For questions, issues, or suggestions, please open an issue on GitHub or contact the maintainer.

---

**Made with ❤️ for better hydration habits**
