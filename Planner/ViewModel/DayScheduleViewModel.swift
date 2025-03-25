import Foundation
import CoreData
import SwiftUI
import Planner

class DayScheduleViewModel: ObservableObject {
    @Published var notes: [NoteModel] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentDate: Date
    
    private let coreDataService = CoreDataService.shared
    private let context: NSManagedObjectContext
    private var notificationToken: NSObjectProtocol?
    
    init(context: NSManagedObjectContext, date: Date = Date()) {
        self.context = context
        self.currentDate = date
        
        notificationToken = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: context,
            queue: .main
        ) { [weak self] _ in
            self?.fetchNotes()
        }
        
        fetchNotes()
    }
    
    deinit {
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // MARK: - Public Methods
    
    func fetchNotes() {
        isLoading = true
        error = nil
        
        do {
            let fetchedNotes = try coreDataService.fetchNotesForDay(currentDate, context: context)
            notes = fetchedNotes.map { NoteModel(note: $0) }
        } catch {
            self.error = error
            print("\(error)")
        }
        
        isLoading = false
    }
    
    func createNote(name: String,
                   descriptionText: String? = nil,
                   time: Date? = nil,
                   duration: Double = 60,
                   category: CategoryModel? = nil) {
        isLoading = true
        error = nil
        
        do {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            if let categoryId = category?.id {
                fetchRequest.predicate = NSPredicate(format: "id == %@", categoryId as CVarArg)
            }
            
            let categoryEntity = try? context.fetch(fetchRequest).first
            
            _ = try coreDataService.createNote(
                in: context,
                name: name,
                descriptionText: descriptionText,
                date: currentDate,
                time: time,
                duration: duration,
                category: categoryEntity
            )
            
            fetchNotes()
        } catch {
            self.error = error
            print("\(error)")
        }
        
        isLoading = false
    }
    
    func updateNote(_ noteModel: NoteModel,
                   name: String? = nil,
                   descriptionText: String? = nil,
                   time: Date? = nil,
                   duration: Double? = nil,
                   category: CategoryModel? = nil) {
        isLoading = true
        error = nil
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", noteModel.id as CVarArg)
        
        do {
            if let note = try context.fetch(fetchRequest).first {
                let categoryEntity: Category?
                if let category = category {
                    let categoryFetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
                    categoryFetchRequest.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
                    categoryEntity = try context.fetch(categoryFetchRequest).first
                } else {
                    categoryEntity = nil
                }
                
                try coreDataService.updateNote(
                    note,
                    name: name,
                    descriptionText: descriptionText,
                    date: nil,
                    time: time,
                    duration: duration,
                    category: categoryEntity,
                    in: context
                )
                
                fetchNotes()
            }
        } catch {
            self.error = error
            print("\(error)")
        }
        
        isLoading = false
    }
    
    func deleteNote(_ noteModel: NoteModel) {
        isLoading = true
        error = nil
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", noteModel.id as CVarArg)
        
        do {
            if let note = try context.fetch(fetchRequest).first {
                try coreDataService.deleteNote(note, in: context)
                fetchNotes()
            }
        } catch {
            self.error = error
            print("\(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    
    func notesForHour(_ hour: Int) -> [NoteModel] {
        return notes.filter { note in
            guard let noteTime = note.time else { return false }
            let noteHour = Calendar.current.component(.hour, from: noteTime)
            return noteHour == hour
        }
    }
    
    func updateDate(_ date: Date) {
        currentDate = date
        fetchNotes()
    }
    
    var currentHour: Int {
        Calendar.current.component(.hour, from: Date())
    }
} 
