import SwiftUI
import CoreData

struct CategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showCalendarView = false
    @State private var showNotesForCategory = false
    @State private var selectedCategory: Category?
    @Binding var selectedDate: Date
    @Binding var showBlurredAlert: Bool
    @Binding var alertSource: AlertSource
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
    ) private var categories: FetchedResults<Category>
    
    init(selectedDate: Binding<Date>, showBlurredAlert: Binding<Bool>, alertSource: Binding<AlertSource>) {
        self._selectedDate = selectedDate
        self._showBlurredAlert = showBlurredAlert
        self._alertSource = alertSource
    }
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }()
    
    private var currentStartDate: Date {
        let today = selectedDate
        if let monday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) {
            return monday
        } else {
            return today
        }
    }
    
    var body: some View {
        if showCalendarView {
            CalendarView(selectedDate: selectedDate, showBlurredAlert: $showBlurredAlert, alertSource: $alertSource)
        } else if showNotesForCategory && selectedCategory != nil {
            CategoryNotesView(category: selectedCategory!, selectedDate: $selectedDate, onBack: {
                showNotesForCategory = false
            })
        } else {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            showCalendarView = true
                        }) {
                            Image("calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                        .padding(.leading, 24)
                        
                        Spacer()
                        
                        Button(action: {
                            alertSource = .category
                            showBlurredAlert = true
                        }) {
                            Image("plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.top, 0)
                    
                    Spacer()
                }
                
                VStack(spacing: 0) {
                    Text("\(currentStartDate.formatted(.dateTime.month(.wide))) \(selectedDate.formatted(.dateTime.day()))")
                        .font(.robotoMedium(size: 24))
                        .padding(.bottom, 30)
                        .padding(.top, 16)
                    
                    if categories.isEmpty {
                        Spacer()
                        Text("No categories yet")
                            .font(.robotoMedium(size: 16))
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(categories) { category in
                                    CategoryItemView(category: category, selectedDate: $selectedDate)
                                        .onTapGesture {
                                            selectedCategory = category
                                            showNotesForCategory = true
                                        }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                deleteCategory(category)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteCategory(_ category: Category) {
        viewContext.delete(category)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("\(nsError)")
        }
    }
}

struct CategoryItemView: View {
    let category: Category
    let selectedDate: Binding<Date>
    @FetchRequest private var notes: FetchedResults<Note>
    
    init(category: Category, selectedDate: Binding<Date>) {
        self.category = category
        self.selectedDate = selectedDate
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate.wrappedValue)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = NSPredicate(format: "category == %@ AND date >= %@ AND date < %@", 
                                   category, startOfDay as NSDate, endOfDay as NSDate)
        let sortDescriptors = [NSSortDescriptor(keyPath: \Note.time, ascending: true)]
        
        self._notes = FetchRequest<Note>(
            sortDescriptors: sortDescriptors,
            predicate: predicate
        )
    }
    
    private var backgroundColor: Color {
        Color(
            red: category.backgroundColorRed,
            green: category.backgroundColorGreen,
            blue: category.backgroundColorBlue,
            opacity: category.backgroundColorAlpha
        )
    }
    
    private var textColor: Color {
        Color(
            red: category.textColorRed,
            green: category.textColorGreen,
            blue: category.textColorBlue,
            opacity: category.textColorAlpha
        )
    }
    
    private var previewNotes: [Note] {
        Array(notes.prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(category.name ?? "")
                    .font(.robotoMedium(size: 18))
                    .foregroundColor(textColor)
                    .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("\(notes.count)")
                    .font(.robotoBold(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                if previewNotes.isEmpty {
                    Text("No tasks yet")
                        .font(.robotoRegular(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                } else {
                    ForEach(previewNotes) { note in
                        Text(note.name ?? "")
                            .font(.robotoRegular(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .frame(height: 80, alignment: .top)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(textColor)
            )
            .padding(.horizontal, 12)
            
            Spacer()
        }
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(backgroundColor)
        )
    }
}

#Preview {
    CategoryView(selectedDate: .constant(Date()), showBlurredAlert: .constant(false), alertSource: .constant(.category))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
