import Foundation
import SwiftUI

struct CategoryModel: Identifiable {
    let id: UUID
    var name: String
    var backgroundColor: Color
    var textColor: Color
    var date: Date?
    var notesCount: Int
    
    init(category: Category) {
        self.id = category.id ?? UUID()
        self.name = category.name ?? ""
        self.backgroundColor = Color(
            red: category.backgroundColorRed,
            green: category.backgroundColorGreen,
            blue: category.backgroundColorBlue,
            alpha: category.backgroundColorAlpha
        )
        self.textColor = Color(
            red: category.textColorRed,
            green: category.textColorGreen,
            blue: category.textColorBlue,
            alpha: category.textColorAlpha
        )
        self.date = category.date
        self.notesCount = category.note?.count ?? 0
    }
    
    init(id: UUID = UUID(), 
         name: String, 
         backgroundColor: Color, 
         textColor: Color,
         date: Date? = nil,
         notesCount: Int = 0) {
        self.id = id
        self.name = name
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.date = date
        self.notesCount = notesCount
    }
} 