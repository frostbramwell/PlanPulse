import SwiftUI

@main
struct PlannerApp: App {
    let persistenceController = PersistenceController.shared
    @State private var isLaunchScreenShowing = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .withAppTheme()
                
                if isLaunchScreenShowing {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isLaunchScreenShowing = false
                    }
                }
            }
        }
    }
}
