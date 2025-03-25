import Foundation
import CoreData
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published var currentStartDate: Date
    private let calendar: Calendar
    
    init(selectedDate: Date = Date()) {
        let calendar = Calendar.current
        self.calendar = calendar
        self.selectedDate = selectedDate
        
        if let monday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) {
            self.currentStartDate = monday
        } else {
            self.currentStartDate = selectedDate
        }
    }
    
    // MARK: - Date Helpers
    
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    func isPastDay(_ date: Date) -> Bool {
        date < calendar.startOfDay(for: Date())
    }
    
    func moveWeek(forward: Bool) {
        if let newDate = calendar.date(byAdding: .day, value: forward ? 7 : -7, to: currentStartDate) {
            currentStartDate = newDate
        }
    }
    
    func getDaysForCurrentWeek() -> [Date] {
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: currentStartDate) ?? currentStartDate
        
        return (0..<21).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: sevenDaysAgo)
        }
    }
    
    // MARK: - Formatting
    
    func formatMonthAndDay() -> String {
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM d"
        return monthFormatter.string(from: selectedDate)
    }
    
    func formatWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
} 
