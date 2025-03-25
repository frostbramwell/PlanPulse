import SwiftUI

enum BackgroundColor: Int, CaseIterable {
    case dark = 0
    case blue = 1
    case purple = 2
    case navy = 3
    
    var color: Color {
        switch self {
        case .dark:
            return Color(red: 24/255, green: 28/255, blue: 31/255)
        case .blue:
            return Color(red: 36/255, green: 52/255, blue: 63/255)
        case .purple:
            return Color(red: 45/255, green: 53/255, blue: 73/255)
        case .navy:
            return Color(red: 24/255, green: 31/255, blue: 52/255)
        }
    }
} 