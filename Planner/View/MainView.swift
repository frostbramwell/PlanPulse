import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .calendar
    @StateObject private var viewModel = SettingsViewModel.shared
    @State private var showBlurredAlert = false
    @State private var alertSource: AlertSource = .calendar
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        ZStack {
            viewModel.selectedBackground.color.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .calendar:
                        CalendarView(selectedDate: selectedDate,
                                   showBlurredAlert: $showBlurredAlert,
                                   alertSource: $alertSource)
                    case .timer:
                        TimerView()
                    case .statistic:
                        StatisticView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxHeight: .infinity)
                
                TabBarView(selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            if showBlurredAlert {
                BlurredAlertView(isPresented: $showBlurredAlert,
                                source: alertSource,
                                selectedDate: selectedDate)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    MainView()
} 
