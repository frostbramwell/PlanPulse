import SwiftUI

enum Tab {
    case calendar
    case timer
    case statistic
    case settings
}

struct TabBarView: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                
                TabButton(imageName: "img1", isSelected: selectedTab == .calendar) {
                    selectedTab = .calendar
                }
                
                Spacer()
                
                TabButton(imageName: "img2", isSelected: selectedTab == .timer) {
                    selectedTab = .timer
                }
                
                Spacer()
                
                TabButton(imageName: "img3", isSelected: selectedTab == .statistic) {
                    selectedTab = .statistic
                }
                
                Spacer()
                
                TabButton(imageName: "img4", isSelected: selectedTab == .settings) {
                    selectedTab = .settings
                }
                
                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
                Rectangle()
                    .fill(Color(red: 59/255, green: 59/255, blue: 59/255, opacity: 0.6))
            }
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

struct TabButton: View {
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(imageName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(isSelected ? .black : .white)
                .padding(8)
                .background(
                    isSelected ? 
                    Circle().fill(.white) : 
                    Circle().fill(Color.clear)
                )
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            TabBarView(selectedTab: .constant(.calendar))
        }
    }
} 
