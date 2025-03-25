import Foundation
import CoreData
import SwiftUI

class BlurredAlertViewModel: ObservableObject {
    @Published var categoryName: String = ""
    @Published var taskName: String = ""
    @Published var taskDescription: String = ""
    @Published var selectedCategory: Category?
    @Published var selectedTime: Date = Date()
    @Published var durationMinutes: Int = 30
    @Published var durationHours: Int = 0
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let context: NSManagedObjectContext
    let source: AlertSource
    let selectedDate: Date
    
    init(context: NSManagedObjectContext, source: AlertSource, selectedDate: Date) {
        self.context = context
        self.source = source
        self.selectedDate = selectedDate
    }
    
    var categories: [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    var hasCategories: Bool {
        !categories.isEmpty
    }
    
    var canCreateCategory: Bool {
        !categoryName.isEmpty
    }
    
    var canCreateTask: Bool {
        !taskName.isEmpty && selectedCategory != nil
    }
    
    func createCategory(completion: @escaping (Bool) -> Void) {
        guard canCreateCategory else {
            completion(false)
            return
        }
        
        isLoading = true
        
        let newCategory = Category(context: context)
        newCategory.id = UUID()
        newCategory.name = categoryName
        newCategory.date = Date()
        
        let colorPair = CategoryColors.getRandomColorPair()
        
        if let components = colorPair.background.cgColor?.components {
            newCategory.backgroundColorRed = components[0]
            newCategory.backgroundColorGreen = components[1]
            newCategory.backgroundColorBlue = components[2]
            newCategory.backgroundColorAlpha = components[3]
        }
        
        if let components = colorPair.text.cgColor?.components {
            newCategory.textColorRed = components[0]
            newCategory.textColorGreen = components[1]
            newCategory.textColorBlue = components[2]
            newCategory.textColorAlpha = components[3]
        }
        
        do {
            try context.save()
            isLoading = false
            completion(true)
        } catch {
            self.error = error
            isLoading = false
            completion(false)
            print("Error saving category: \(error)")
        }
    }
    
    func createTask(completion: @escaping (Bool) -> Void) {
        guard canCreateTask else {
            completion(false)
            return
        }
        
        isLoading = true
        
        let newNote = Note(context: context)
        newNote.id = UUID()
        newNote.name = taskName
        newNote.descriptionText = taskDescription
        newNote.category = selectedCategory
        
        let calendar = Calendar.current
        newNote.date = calendar.startOfDay(for: selectedDate)
        newNote.time = selectedTime
        newNote.duration = Double(durationHours * 60 + durationMinutes)
        
        do {
            try context.save()
            isLoading = false
            completion(true)
        } catch {
            self.error = error
            isLoading = false
            completion(false)
            print("Error saving note: \(error)")
        }
    }
    
    func resetForm() {
        categoryName = ""
        taskName = ""
        taskDescription = ""
        selectedCategory = nil
        selectedTime = Date()
        durationMinutes = 30
        durationHours = 0
        error = nil
    }
} 