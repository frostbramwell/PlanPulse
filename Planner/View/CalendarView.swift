import SwiftUI
import CoreData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CalendarViewModel
    @State private var showCategoryView = false
    @Binding var showBlurredAlert: Bool
    @Binding var alertSource: AlertSource
    
    init(selectedDate: Date, showBlurredAlert: Binding<Bool>, alertSource: Binding<AlertSource>) {
        self._viewModel = StateObject(wrappedValue: CalendarViewModel(selectedDate: selectedDate))
        self._showBlurredAlert = showBlurredAlert
        self._alertSource = alertSource
    }
    
    var body: some View {
        if showCategoryView {
            CategoryView(selectedDate: .init(get: { viewModel.selectedDate },
                                          set: { viewModel.selectedDate = $0 }),
                        showBlurredAlert: $showBlurredAlert,
                        alertSource: $alertSource)
        } else {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: {
                            showCategoryView = true
                        }) {
                            Image("category")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                        .padding(.leading, 40)
                        
                        Spacer()
                        
                        Button(action: {
                            alertSource = .calendar
                            showBlurredAlert = true
                        }) {
                            Image("plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                        .padding(.trailing, 40)
                    }
                    .padding(.top, 0)
                    
                    WeekView(calendarViewModel: viewModel)
                        .padding(.bottom, 20)
                    
                    DayScheduleView(date: viewModel.selectedDate, context: viewContext)
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }
}

struct WeekView: View {
    @ObservedObject var calendarViewModel: CalendarViewModel
    @StateObject private var viewModel = WeekViewModel()
    private let cellWidth: CGFloat = UIScreen.main.bounds.width / 7
    
    var body: some View {
        VStack(spacing: 0) {
            Text(calendarViewModel.formatMonthAndDay())
                .font(.robotoMedium(size: 24))
                .padding(.top, -24)
                .padding(.bottom, 30)
            
            VStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        ForEach(viewModel.allDays, id: \.self) { date in
                            Text(viewModel.formatWeekday(date))
                                .font(.robotoRegular(size: 12))
                                .foregroundColor(Color(red: 142/255, green: 145/255, blue: 151/255, opacity: 1))
                                .frame(width: cellWidth)
                        }
                    }
                    .offset(x: -7 * cellWidth + viewModel.dragOffset)
                }
                .frame(width: 7 * cellWidth, alignment: .leading)
                .clipped()
                
                ZStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        ForEach(viewModel.allDays, id: \.self) { date in
                            DayCell(date: date,
                                   isSelected: viewModel.isDateSelected(date, selectedDate: calendarViewModel.selectedDate),
                                   isCurrentMonth: true)
                                .onTapGesture {
                                    withAnimation {
                                        calendarViewModel.selectedDate = date
                                        viewModel.updateCurrentStartDate(for: date)
                                    }
                                }
                                .frame(width: cellWidth)
                                .contentShape(Rectangle())
                        }
                    }
                    .offset(x: -7 * cellWidth + viewModel.dragOffset)
                }
                .frame(width: 7 * cellWidth, alignment: .leading)
                .clipped()
            }
            .frame(height: 60)
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        viewModel.handleDragGesture(value: value)
                    }
                    .onEnded { _ in
                        viewModel.handleDragEnd()
                    }
            )
        }
        .padding(.horizontal)
        .onChange(of: calendarViewModel.selectedDate) { newDate in
            viewModel.updateCurrentStartDate(for: newDate)
        }
    }
}

struct DayCell: View {
    @ObservedObject private var viewModel: DayViewModel
    
    init(date: Date, isSelected: Bool, isCurrentMonth: Bool) {
        self.viewModel = DayViewModel(
            date: date,
            isSelected: isSelected,
            isCurrentMonth: isCurrentMonth
        )
    }
    
    var body: some View {
        VStack {
            Text(viewModel.dayNumber)
                .foregroundColor(viewModel.textColor)
                .font(viewModel.font)
        }
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(viewModel.backgroundDecoration)
        .foregroundColor(viewModel.isCurrentMonth ? .primary : .gray.opacity(0.5))
    }
}

struct HourRow: View {
    @StateObject private var viewModel: HourViewModel
    
    init(hour: Int, date: Date) {
        self._viewModel = StateObject(wrappedValue: HourViewModel(hour: hour, date: date))
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Text(viewModel.formattedHour)
                .font(.robotoRegular(size: 14))
                .rotationEffect(.degrees(-90))
                .frame(width: 50)
                .foregroundColor(viewModel.textColor)
            
            Rectangle()
                .fill(viewModel.lineColor)
                .frame(height: 1)
        }
        .frame(height: 70)
        .padding(.horizontal)
        .id(viewModel.hour)
    }
}

struct NoteView: View {
    @StateObject private var viewModel: NoteViewModel
    
    init(note: NoteModel) {
        self._viewModel = StateObject(wrappedValue: NoteViewModel(note: note))
    }
    
    var body: some View {
        HStack {
            Text(viewModel.title)
                .font(.robotoMedium(size: 14))
                .foregroundColor(viewModel.textColor)
                .lineLimit(1)
            
            Spacer()
            
            Text(viewModel.timeText)
                .font(.robotoRegular(size: 12))
                .foregroundColor(viewModel.textColor)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(viewModel.backgroundColor)
        .cornerRadius(8)
    }
}

struct DayScheduleView: View {
    @StateObject private var viewModel: DayScheduleViewModel
    private let hourHeight: CGFloat = 70
    private let date: Date
    @State private var hasAppeared = false
    
    init(date: Date, context: NSManagedObjectContext) {
        self.date = date
        self._viewModel = StateObject(wrappedValue: DayScheduleViewModel(context: context, date: date))
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: true) {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        ForEach(0..<25) { hour in
                            HourRow(hour: hour, date: viewModel.currentDate)
                                .id(hour)
                        }
                        
                        Spacer()
                            .frame(height: 80)
                    }
                    
                    VStack(spacing: 0) {
                        ForEach(0..<25) { hourIndex in
                            HStack {
                                Spacer()
                                    .frame(width: 70)
                                
                                ZStack(alignment: .topLeading) {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: hourHeight)
                                    
                                    ForEach(viewModel.notesForHour(hourIndex), id: \.id) { note in
                                        if let _ = note.time {
                                            NoteView(note: note)
                                                .frame(height: note.duration / 60.0 * hourHeight)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 16)
                                                .offset(y: calculateVerticalOffset(for: note, hourHeight: hourHeight))
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(height: hourHeight)
                        }
                        
                        Spacer()
                            .frame(height: 80)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                if !hasAppeared {
                    hasAppeared = true
                    scrollToCurrentTime(proxy: proxy)
                }
            }
            .onChange(of: date) { newDate in
                viewModel.updateDate(newDate)
                scrollToCurrentTime(proxy: proxy)
            }
        }
    }
    
    private func scrollToCurrentTime(proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            let calendar = Calendar.current
            if calendar.isDate(date, inSameDayAs: Date()) {
                let currentHour = calendar.component(.hour, from: Date())
                let targetHour = max(0, currentHour - 1)
                withAnimation {
                    proxy.scrollTo(targetHour, anchor: .top)
                }
            } else {
                withAnimation {
                    proxy.scrollTo(8, anchor: .top)
                }
            }
        }
    }
    
    private func calculateVerticalOffset(for note: NoteModel, hourHeight: CGFloat) -> CGFloat {
        guard let noteTime = note.time else { return 0 }
        let minute = Calendar.current.component(.minute, from: noteTime)
        return CGFloat(minute) / 60.0 * hourHeight + 35
    }
}

#Preview {
    CalendarView(selectedDate: Date(), showBlurredAlert: .constant(false), alertSource: .constant(.calendar))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}



