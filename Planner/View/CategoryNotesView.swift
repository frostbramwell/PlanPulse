import SwiftUI
import CoreData
import UIKit

private func getStatusBarHeight() -> CGFloat {
    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    return scene?.statusBarManager?.statusBarFrame.height ?? 20
}

struct CategoryNotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CategoryNotesViewModel
    @Binding var selectedDate: Date
    let category: Category
    let onBack: () -> Void
    
    init(category: Category, selectedDate: Binding<Date>, onBack: @escaping () -> Void) {
        self.category = category
        self._selectedDate = selectedDate
        self.onBack = onBack
        self._viewModel = StateObject(wrappedValue: CategoryNotesViewModel(
            category: category,
            context: PersistenceController.shared.container.viewContext,
            initialDate: selectedDate.wrappedValue
        ))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                if !viewModel.hasNotes {
                    Spacer()
                    Text("No tasks yet")
                        .font(.robotoMedium(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.notes) { note in
                            NoteItemView(note: note)
                                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                                .listRowBackground(Color.clear)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteNote(note)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                }
            }
            .padding(.top, 90)
            
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: getStatusBarHeight())
                
                ZStack {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                                .opacity(0)
                        }
                        .padding(.trailing, 24)
                    }
                    
                    Text(viewModel.categoryName)
                        .font(.robotoBold(size: 24))
                        .foregroundColor(.white)
                }
                .frame(height: 44)
                .padding(.bottom, 10)
            }
            .background(Color.clear)
        }
        .ignoresSafeArea(edges: .top)
        .onChange(of: selectedDate) { newDate in
            viewModel.fetchNotes(for: newDate)
        }
    }
}

struct NoteItemView: View {
    let note: Note
    @StateObject private var viewModel: CategoryNotesViewModel
    
    init(note: Note) {
        self.note = note
        self._viewModel = StateObject(wrappedValue: CategoryNotesViewModel(
            category: note.category!,
            context: PersistenceController.shared.container.viewContext,
            initialDate: note.date ?? Date()
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.name ?? "")
                    .font(.robotoBold(size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(viewModel.formattedTime(for: note))
                    .font(.robotoRegular(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            if let description = note.descriptionText, !description.isEmpty {
                Text(description)
                    .font(.robotoRegular(size: 14))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(viewModel.backgroundColor)
        )
    }
} 
