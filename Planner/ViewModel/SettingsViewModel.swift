import SwiftUI

class SettingsViewModel: ObservableObject {
    static let shared = SettingsViewModel()
    
    @Published var selectedBackground: BackgroundColor {
        didSet {
            UserDefaults.standard.set(selectedBackground.rawValue, forKey: "selectedBackground")
        }
    }
    
    init() {
        let colorValue = UserDefaults.standard.integer(forKey: "selectedBackground")
        if let color = BackgroundColor(rawValue: colorValue) {
            self.selectedBackground = color
        } else {
            self.selectedBackground = .dark
        }
    }
} 