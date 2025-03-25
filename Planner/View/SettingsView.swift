import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose your\nbackground")
                .font(.robotoLight(size: 32))
                .multilineTextAlignment(.center)
                .padding(.top, 30)
            
            HStack(spacing: 15) {
                ForEach(BackgroundColor.allCases, id: \.rawValue) { bgColor in
                    ColorButton(color: bgColor.color, 
                              isSelected: viewModel.selectedBackground == bgColor) {
                        viewModel.selectedBackground = bgColor
                    }
                }
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
    }
}

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.green : Color.gray, lineWidth: 3)
                )
        }
    }
}

#Preview {
    SettingsView()
}
