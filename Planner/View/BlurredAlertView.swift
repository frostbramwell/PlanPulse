import SwiftUI
import CoreData

struct BlurredAlertView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: BlurredAlertViewModel
    @Binding var isPresented: Bool
    @FocusState private var isTextFieldFocused: Bool
    
    init(isPresented: Binding<Bool>, source: AlertSource, selectedDate: Date = Date()) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: BlurredAlertViewModel(
            context: PersistenceController.shared.container.viewContext,
            source: source,
            selectedDate: selectedDate
        ))
        
        UITextField.appearance().keyboardAppearance = .dark
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                if viewModel.source == .category {
                    categoryView
                } else if viewModel.source == .calendar {
                    taskView(geometry: geometry)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private var categoryView: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image("close")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                .padding(.trailing, 24)
                .padding(.top, 48)
            }
            
            Text("Add new category")
                .font(.robotoBold(size: 28))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            TextField("", text: $viewModel.categoryName)
                .placeholder(when: viewModel.categoryName.isEmpty) {
                    Text("Category name")
                        .foregroundColor(Color(red: 142/255, green: 145/255, blue: 151/255, opacity: 1))
                        .font(.robotoRegular(size: 18))
                }
                .textFieldStyle(CustomTextFieldStyle())
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .focused($isTextFieldFocused)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isTextFieldFocused = true
                    }
                }
            
            Spacer()
            
            Button(action: {
                viewModel.createCategory { success in
                    if success {
                        isPresented = false
                    }
                }
            }) {
                Text("Create a category")
                    .font(.robotoMedium(size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color(red: 165/255, green: 255/255, blue: 110/255, opacity: 1))
                    )
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 35)
            .opacity(viewModel.canCreateCategory ? 1.0 : 0.6)
            .disabled(!viewModel.canCreateCategory)
        }
    }
    
    private func taskView(geometry: GeometryProxy) -> some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image("close")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                .padding(.trailing, 24)
                .padding(.top, 48)
            }
            
            Text("Add new task")
                .font(.robotoBold(size: 28))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            TextField("", text: $viewModel.taskName)
                .placeholder(when: viewModel.taskName.isEmpty) {
                    Text("Task name")
                        .foregroundColor(Color(red: 142/255, green: 145/255, blue: 151/255, opacity: 1))
                        .font(.robotoRegular(size: 18))
                }
                .textFieldStyle(CustomTextFieldStyle())
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .focused($isTextFieldFocused)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isTextFieldFocused = true
                    }
                }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Description")
                        .font(.robotoMedium(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                    
                    ZStack(alignment: .topLeading) {
                        if viewModel.taskDescription.isEmpty {
                            Text("Description")
                                .foregroundColor(Color(red: 142/255, green: 145/255, blue: 151/255, opacity: 1))
                                .font(.robotoRegular(size: 18))
                                .padding(.horizontal, 25)
                                .padding(.top, 10)
                        }
                        
                        TextEditor(text: $viewModel.taskDescription)
                            .foregroundColor(.white)
                            .font(.robotoRegular(size: 18))
                            .padding(.horizontal, 20)
                            .frame(minHeight: 60)
                            .background(Color.clear)
                            .colorScheme(.dark)
                            .scrollContentBackground(.hidden)
                    }
                    .padding(.horizontal, 5)
                    
                    Text("Category")
                        .font(.robotoMedium(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.top, 15)
                    
                    if !viewModel.hasCategories {
                        Text("No categories available")
                            .font(.robotoRegular(size: 16))
                            .foregroundColor(Color(red: 142/255, green: 145/255, blue: 151/255, opacity: 1))
                            .padding(.horizontal, 25)
                    } else {
                        Picker("Category", selection: $viewModel.selectedCategory) {
                            Text("Select category")
                                .foregroundColor(Color(red: 142/255, green: 145/255, blue: 151/255, opacity: 1))
                                .tag(nil as Category?)
                            
                            ForEach(viewModel.categories) { category in
                                Text(category.name ?? "")
                                    .foregroundColor(.white)
                                    .tag(category as Category?)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 80)
                        .padding(.horizontal, 25)
                        .clipped()
                        .colorScheme(.dark)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    }
                    
                    Text("Start time")
                        .font(.robotoMedium(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                    
                    DatePicker("", selection: $viewModel.selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 80)
                        .padding(.horizontal, 25)
                        .colorScheme(.dark)
                        .clipped()
                        .frame(maxWidth: .infinity)
                    
                    Text("Duration")
                        .font(.robotoMedium(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                    
                    HStack(spacing: 0) {
                        VStack {
                            Text("Hours")
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(Color(red: 142/255, green: 145/255, blue: 151/255, opacity: 1))
                                .padding(.bottom, 5)
                            
                            Picker("Hours", selection: $viewModel.durationHours) {
                                ForEach(0...12, id: \.self) { hour in
                                    Text("\(hour)")
                                        .foregroundColor(.white)
                                        .tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 80)
                            .clipped()
                            .colorScheme(.dark)
                        }
                        .frame(width: geometry.size.width * 0.4)
                        
                        VStack {
                            Text("Minutes")
                                .font(.robotoRegular(size: 14))
                                .foregroundColor(Color(red: 142/255, green: 145/255, blue: 151/255, opacity: 1))
                                .padding(.bottom, 5)
                            
                            Picker("Minutes", selection: $viewModel.durationMinutes) {
                                ForEach([0, 15, 30, 45], id: \.self) { minute in
                                    Text("\(minute)")
                                        .foregroundColor(.white)
                                        .tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 80)
                            .clipped()
                            .colorScheme(.dark)
                        }
                        .frame(width: geometry.size.width * 0.4)
                    }
                    .padding(.horizontal, 25)
                }
            }
            
            Button(action: {
                viewModel.createTask { success in
                    if success {
                        isPresented = false
                    }
                }
            }) {
                Text("Create a task")
                    .font(.robotoMedium(size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color(red: 165/255, green: 255/255, blue: 110/255, opacity: 1))
                    )
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 35)
            .opacity(viewModel.canCreateTask ? 1.0 : 0.6)
            .disabled(!viewModel.canCreateTask)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        VStack {
            configuration
                .foregroundColor(.white)
                .font(.robotoRegular(size: 18))
                .padding(.vertical, 10)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.3))
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
} 
