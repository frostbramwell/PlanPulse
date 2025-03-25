import Foundation
import SwiftUI
import CoreData

class NoteViewModel: ObservableObject {
    private let calendar = Calendar.current
    private let pastColor = Color(red: 142/255, green: 145/255, blue: 151/255, opacity: 1)
    
    let note: NoteModel
    
    init(note: NoteModel) {
        self.note = note
    }
    
    var isPastEvent: Bool {
        guard let noteTime = note.time else {
            return false
        }
        
        let currentDate = Date()
        
        if calendar.isDate(note.date, inSameDayAs: currentDate) {
            let durationInMinutes = Int(note.duration)
            if let endTime = calendar.date(byAdding: .minute, value: durationInMinutes, to: noteTime) {
                return currentDate > endTime
            }
            return currentDate > noteTime
        }
        
        return note.date < calendar.startOfDay(for: currentDate)
    }
    
    var backgroundColor: Color {
        if isPastEvent {
            return pastColor.opacity(0.5)
        }
        
        if let category = note.category {
            return category.backgroundColor
        }
        return Color.blue.opacity(0.7)
    }
    
    var textColor: Color {
        isPastEvent ? pastColor : .white
    }
    
    var timeText: String {
        guard let noteTime = note.time else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let startTime = formatter.string(from: noteTime)
        
        if let endTime = calendar.date(byAdding: .minute, value: Int(note.duration), to: noteTime) {
            let endTimeString = formatter.string(from: endTime)
            return "\(startTime)-\(endTimeString)"
        }
        
        return startTime
    }
    
    var title: String {
        note.name
    }
    
    var height: CGFloat {
        let hourHeight: CGFloat = 70
        return max(CGFloat(note.duration) / 60.0 * hourHeight, 30)
    }
    
    func verticalOffset(hourHeight: CGFloat) -> CGFloat {
        guard let noteTime = note.time else { return 0 }
        let minute = calendar.component(.minute, from: noteTime)
        return CGFloat(minute) / 60.0 * hourHeight + 35
    }
} 
