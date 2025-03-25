import Foundation
import SwiftUI

class DayViewModel: ObservableObject {
    private let calendar = Calendar.current
    private let pastColor = Color(red: 142/255, green: 145/255, blue: 151/255, opacity: 1)
    private let selectedColor = Color(red: 165/255, green: 255/255, blue: 110/255, opacity: 1)
    private let todayStrokeColor = Color(red: 119/255, green: 255/255, blue: 138/255, opacity: 1)
    
    @Published var date: Date
    @Published var isSelected: Bool
    @Published var isCurrentMonth: Bool
    
    init(date: Date, isSelected: Bool, isCurrentMonth: Bool) {
        self.date = date
        self.isSelected = isSelected
        self.isCurrentMonth = isCurrentMonth
    }
    
    var isPastDay: Bool {
        date < calendar.startOfDay(for: Date())
    }
    
    var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var dayNumber: String {
        date.formatted(.dateTime.day())
    }
    
    var textColor: Color {
        if isSelected {
            return .black
        }
        return isPastDay ? pastColor : .white
    }
    
    var font: Font {
        isToday ? .robotoBold(size: 20) : .robotoRegular(size: 20)
    }
    
    var backgroundDecoration: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(selectedColor)
                    .frame(width: 40, height: 40)
            }
            if isToday && !isSelected {
                Circle()
                    .stroke(todayStrokeColor, lineWidth: 3)
                    .frame(width: 40, height: 40)
            }
        }
    }
} 