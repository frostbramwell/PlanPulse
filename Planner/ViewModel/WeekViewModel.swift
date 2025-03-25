import Foundation
import SwiftUI

class WeekViewModel: ObservableObject {
    @Published var currentStartDate: Date
    @Published var dragOffset: CGFloat = 0
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 
        return calendar
    }()
    
    init() {
        let today = Date()
        if let monday = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) {
            self.currentStartDate = monday
        } else {
            self.currentStartDate = today
        }
    }
    
    var allDays: [Date] {
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: currentStartDate) ?? currentStartDate
        
        return (0..<21).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: sevenDaysAgo)
        }
    }
    
    func handleDragGesture(value: DragGesture.Value) {
        dragOffset = value.translation.width
    }
    
    func handleDragEnd() {
        let threshold: CGFloat = 50
        
        if dragOffset > threshold {
            withAnimation {
                if let newDate = calendar.date(byAdding: .day, value: -7, to: currentStartDate) {
                    currentStartDate = newDate
                }
            }
        } else if dragOffset < -threshold {
            withAnimation {
                if let newDate = calendar.date(byAdding: .day, value: 7, to: currentStartDate) {
                    currentStartDate = newDate
                }
            }
        }
        
        withAnimation(.interactiveSpring()) {
            dragOffset = 0
        }
    }
    
    func formatWeekday(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated)).prefix(1).uppercased()
    }
    
    func isDateSelected(_ date: Date, selectedDate: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    func updateCurrentStartDate(for selectedDate: Date) {
        if let monday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) {
            withAnimation {
                self.currentStartDate = monday
            }
        }
    }
} 
