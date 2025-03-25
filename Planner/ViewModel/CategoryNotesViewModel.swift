import Foundation
import CoreData
import SwiftUI

class CategoryNotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let category: Category
    private let context: NSManagedObjectContext
    private var currentDate: Date
    
    init(category: Category, context: NSManagedObjectContext, initialDate: Date) {
        self.category = category
        self.context = context
        self.currentDate = initialDate
        fetchNotes(for: initialDate)
    }
    
    func fetchNotes(for date: Date) {
        isLoading = true
        error = nil
        currentDate = date
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@ AND date >= %@ AND date < %@",
                                           category, startOfDay as NSDate, endOfDay as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Note.time, ascending: true)]
        
        do {
            notes = try context.fetch(fetchRequest)
        } catch {
            self.error = error
            print("Error fetching notes: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteNote(_ note: Note) {
        do {
            context.delete(note)
            try context.save()
            fetchNotes(for: currentDate)
        } catch {
            self.error = error
            print("Error deleting note: \(error)")
        }
    }
    
    func formattedTime(for note: Note) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let duration = Int(note.duration)
        let timeString = note.time.map { formatter.string(from: $0) } ?? ""
        
        return "\(timeString) • \(duration) min"
    }
    
    var categoryName: String {
        category.name ?? ""
    }
    
    var hasNotes: Bool {
        !notes.isEmpty
    }
    
    var backgroundColor: Color {
        Color(
            red: category.backgroundColorRed,
            green: category.backgroundColorGreen,
            blue: category.backgroundColorBlue,
            opacity: category.backgroundColorAlpha
        )
    }
} 
