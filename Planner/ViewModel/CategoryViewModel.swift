import Foundation
import CoreData
import SwiftUI

class CategoryViewModel: ObservableObject {
    @Published var categories: [CategoryModel] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let coreDataService = CoreDataService.shared
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchCategories()
    }
    
    // MARK: - Public Methods
    
    func fetchCategories() {
        isLoading = true
        error = nil
        
        do {
            let fetchedCategories = try coreDataService.fetchCategories(context: context)
            categories = fetchedCategories.map { CategoryModel(category: $0) }
        } catch {
            self.error = error
            print("\(error)")
        }
        
        isLoading = false
    }
    
    func createCategory(name: String, backgroundColor: Color, textColor: Color, date: Date? = nil) {
        isLoading = true
        error = nil
        
        do {
            _ = try coreDataService.createCategory(
                in: context,
                name: name,
                backgroundColor: backgroundColor,
                textColor: textColor,
                date: date
            )
            fetchCategories()
        } catch {
            self.error = error
            print("\(error)")
        }
        
        isLoading = false
    }
    
    func updateCategory(_ categoryModel: CategoryModel,
                       name: String? = nil,
                       backgroundColor: Color? = nil,
                       textColor: Color? = nil,
                       date: Date? = nil) {
        isLoading = true
        error = nil
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryModel.id as CVarArg)
        
        do {
            if let category = try context.fetch(fetchRequest).first {
                try coreDataService.updateCategory(
                    category,
                    name: name,
                    backgroundColor: backgroundColor,
                    textColor: textColor,
                    date: date,
                    in: context
                )
                fetchCategories()
            }
        } catch {
            self.error = error
            print("\(error)")
        }
        
        isLoading = false
    }
    
    func deleteCategory(_ categoryModel: CategoryModel) {
        isLoading = true
        error = nil
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", categoryModel.id as CVarArg)
        
        do {
            if let category = try context.fetch(fetchRequest).first {
                try coreDataService.deleteCategory(category, in: context)
                fetchCategories()
            }
        } catch {
            self.error = error
            print("\(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    
    func category(for id: UUID) -> CategoryModel? {
        categories.first { $0.id == id }
    }
    
    func categoryName(for id: UUID) -> String {
        category(for: id)?.name ?? ""
    }
    
    func categoryColor(for id: UUID) -> Color {
        category(for: id)?.backgroundColor ?? .blue
    }
} 
