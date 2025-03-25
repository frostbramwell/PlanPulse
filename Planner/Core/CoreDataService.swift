import Foundation
import CoreData
import SwiftUI

class CoreDataService {
    static let shared = CoreDataService()
    private let calendar = Calendar.current
    
    private init() {}
    
    // MARK: - Notes
    
    func fetchNotesForDay(_ date: Date, context: NSManagedObjectContext) throws -> [Note] {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        let sortDescriptors = [NSSortDescriptor(keyPath: \Note.time, ascending: true)]
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        return try context.fetch(fetchRequest)
    }
    
    func notesForHour(_ hour: Int, from notes: [Note]) -> [Note] {
        return notes.filter { note in
            guard let noteTime = note.time else { return false }
            let noteHour = calendar.component(.hour, from: noteTime)
            return noteHour == hour
        }
    }
    
    func createNote(in context: NSManagedObjectContext,
                   name: String,
                   descriptionText: String? = nil,
                   date: Date,
                   time: Date? = nil,
                   duration: Double = 60,
                   category: Category? = nil) throws -> Note {
        let note = Note(context: context)
        note.id = UUID()
        note.name = name
        note.descriptionText = descriptionText
        note.date = date
        note.time = time
        note.duration = duration
        note.category = category
        
        try context.save()
        return note
    }
    
    func updateNote(_ note: Note,
                   name: String? = nil,
                   descriptionText: String? = nil,
                   date: Date? = nil,
                   time: Date? = nil,
                   duration: Double? = nil,
                   category: Category? = nil,
                   in context: NSManagedObjectContext) throws {
        if let name = name { note.name = name }
        if let descriptionText = descriptionText { note.descriptionText = descriptionText }
        if let date = date { note.date = date }
        if let time = time { note.time = time }
        if let duration = duration { note.duration = duration }
        if let category = category { note.category = category }
        
        try context.save()
    }
    
    func deleteNote(_ note: Note, in context: NSManagedObjectContext) throws {
        context.delete(note)
        try context.save()
    }
    
    // MARK: - Categories
    
    func fetchCategories(context: NSManagedObjectContext) throws -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return try context.fetch(request)
    }
    
    func createCategory(in context: NSManagedObjectContext,
                       name: String,
                       backgroundColor: Color,
                       textColor: Color,
                       date: Date? = nil) throws -> Category {
        let category = Category(context: context)
        category.id = UUID()
        category.name = name
        category.date = date
        
        let bgComponents = backgroundColor.components
        category.backgroundColorRed = bgComponents.red
        category.backgroundColorGreen = bgComponents.green
        category.backgroundColorBlue = bgComponents.blue
        category.backgroundColorAlpha = bgComponents.alpha
        
        let textComponents = textColor.components
        category.textColorRed = textComponents.red
        category.textColorGreen = textComponents.green
        category.textColorBlue = textComponents.blue
        category.textColorAlpha = textComponents.alpha
        
        try context.save()
        return category
    }
    
    func updateCategory(_ category: Category,
                       name: String? = nil,
                       backgroundColor: Color? = nil,
                       textColor: Color? = nil,
                       date: Date? = nil,
                       in context: NSManagedObjectContext) throws {
        if let name = name { category.name = name }
        if let date = date { category.date = date }
        
        if let backgroundColor = backgroundColor {
            let components = backgroundColor.components
            category.backgroundColorRed = components.red
            category.backgroundColorGreen = components.green
            category.backgroundColorBlue = components.blue
            category.backgroundColorAlpha = components.alpha
        }
        
        if let textColor = textColor {
            let components = textColor.components
            category.textColorRed = components.red
            category.textColorGreen = components.green
            category.textColorBlue = components.blue
            category.textColorAlpha = components.alpha
        }
        
        try context.save()
    }
    
    func deleteCategory(_ category: Category, in context: NSManagedObjectContext) throws {
        context.delete(category)
        try context.save()
    }
}

// MARK: - Color Extensions

extension Color {
    var components: (red: Double, green: Double, blue: Double, alpha: Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let uiColor = UIColor(self)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
    
    init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), opacity: CGFloat(alpha))
    }
} 
