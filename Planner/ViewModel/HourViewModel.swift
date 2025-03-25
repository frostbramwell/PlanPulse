import Foundation
import SwiftUI

class HourViewModel: ObservableObject {
    private let calendar = Calendar.current
    private let pastColor = Color(red: 142/255, green: 145/255, blue: 151/255, opacity: 1)
    
    let hour: Int
    let date: Date
    
    init(hour: Int, date: Date) {
        self.hour = hour
        self.date = date
    }
    
    var isPastHour: Bool {
        if !calendar.isDateInToday(date) {
            return calendar.startOfDay(for: date) < calendar.startOfDay(for: Date())
        }
        let currentHour = calendar.component(.hour, from: Date())
        return hour < currentHour
    }
    
    var formattedHour: String {
        String(format: "%02d:00", hour)
    }
    
    var textColor: Color {
        isPastHour ? pastColor : .white
    }
    
    var lineColor: Color {
        isPastHour ? pastColor : Color.gray.opacity(0.5)
    }
} 