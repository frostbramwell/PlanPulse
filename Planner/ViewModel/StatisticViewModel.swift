import Foundation
import CoreData
import SwiftUI

class StatisticViewModel: ObservableObject {
    @Published var statisticsData: [StatisticData] = []
    @Published var selectedPeriod: StatisticPeriod = .week
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        updateStatistics()
    }
    
    func updateStatistics() {
        let result = fetchNotesCount(for: selectedPeriod)
        print("Fetched statistics for \(selectedPeriod): \(result.map { "\($0.label): \($0.count)" }.joined(separator: ", "))")
        statisticsData = result
    }
    
    func maxCountValue() -> Int {
        let maxValue = statisticsData.map { $0.count }.max() ?? 0
        return max(maxValue, 1)
    }
    
    private func fetchNotesCount(for period: StatisticPeriod) -> [StatisticData] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .week:
            return fetchWeeklyStatistics(calendar: calendar, now: now)
        case .month:
            return fetchMonthlyStatistics(calendar: calendar, now: now)
        case .halfYear:
            return fetchLastSixMonthsStatistics(calendar: calendar, now: now)
        case .year:
            return fetchYearlyStatistics(calendar: calendar, now: now)
        }
    }
    
    private func fetchWeeklyStatistics(calendar: Calendar, now: Date) -> [StatisticData] {
        var result: [StatisticData] = []
        let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        
        let weekday = calendar.component(.weekday, from: now)
        let daysToSubtract = weekday == 1 ? 6 : weekday - 2
        let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: calendar.startOfDay(for: now))!
        
        for i in 0..<7 {
            let day = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
            let count = countNotes(from: day, to: calendar.date(byAdding: .day, value: 1, to: day)!)
            result.append(StatisticData(label: daysOfWeek[i], count: count))
        }
        
        return result
    }
    
    private func fetchMonthlyStatistics(calendar: Calendar, now: Date) -> [StatisticData] {
        var result: [StatisticData] = []
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let range = calendar.range(of: .day, in: .month, for: now)!
        let numberOfDays = range.count
        
        let weeksInMonth = min(4, numberOfDays / 7 + (numberOfDays % 7 > 0 ? 1 : 0))
        
        for i in 0..<weeksInMonth {
            let weekStart = calendar.date(byAdding: .day, value: i * 7, to: startOfMonth)!
            let weekEnd = i < weeksInMonth - 1 
                ? calendar.date(byAdding: .day, value: (i + 1) * 7, to: startOfMonth)!
                : calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            
            let count = countNotes(from: weekStart, to: weekEnd)
            result.append(StatisticData(label: "W\(i+1)", count: count))
        }
        
        return result
    }
    
    private func fetchLastSixMonthsStatistics(calendar: Calendar, now: Date) -> [StatisticData] {
        var result: [StatisticData] = []
        let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        for i in 0..<6 {
            let monthOffset = (currentMonth - 1 - i) % 12
            let monthIndex = monthOffset >= 0 ? monthOffset : monthOffset + 12
            
            let yearOffset = (currentMonth - 1 - i) < 0 ? -1 : 0
            let year = currentYear + yearOffset
            
            let monthComponents = DateComponents(year: year, month: monthIndex + 1)
            guard let startOfMonth = calendar.date(from: monthComponents) else { continue }
            guard let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else { continue }
            
            let count = countNotes(from: startOfMonth, to: endOfMonth)
            result.append(StatisticData(label: monthNames[monthIndex], count: count))
        }
        
        return result.reversed()
    }
    
    private func fetchYearlyStatistics(calendar: Calendar, now: Date) -> [StatisticData] {
        var result: [StatisticData] = []
        
        let year = calendar.component(.year, from: now)
        let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        for i in 0..<12 {
            let monthComponents = DateComponents(year: year, month: i + 1)
            guard let startOfMonth = calendar.date(from: monthComponents) else { continue }
            guard let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else { continue }
            
            let count = countNotes(from: startOfMonth, to: endOfMonth)
            result.append(StatisticData(label: monthNames[i], count: count))
        }
        
        return result
    }
    
    private func countNotes(from startDate: Date, to endDate: Date) -> Int {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        
        do {
            return try viewContext.count(for: fetchRequest)
        } catch {
            print("Error fetching note count: \(error)")
            return 0
        }
    }
} 