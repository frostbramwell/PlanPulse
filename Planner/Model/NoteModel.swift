import Foundation

struct NoteModel: Identifiable {
    let id: UUID
    var name: String
    var descriptionText: String?
    var date: Date
    var time: Date?
    var duration: Double
    var category: CategoryModel?
    
    init(note: Note) {
        self.id = note.id ?? UUID()
        self.name = note.name ?? ""
        self.descriptionText = note.descriptionText
        self.date = note.date ?? Date()
        self.time = note.time
        self.duration = note.duration
        if let category = note.category {
            self.category = CategoryModel(category: category)
        }
    }
    
    init(id: UUID = UUID(),
         name: String,
         descriptionText: String? = nil,
         date: Date,
         time: Date? = nil,
         duration: Double = 60,
         category: CategoryModel? = nil) {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
        self.date = date
        self.time = time
        self.duration = duration
        self.category = category
    }
} 