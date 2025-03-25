import SwiftUI

struct TimerView: View {
    @StateObject private var settings = SettingsViewModel.shared
    @StateObject private var viewModel = TimerViewModel()
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 30)
                .frame(width: 300, height: 300)
            
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(viewModel.progressColor, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                .frame(width: 300, height: 300)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: viewModel.progress)
            
            VStack(spacing: 20) {
                ZStack {
                    Text(viewModel.statusText)
                        .font(.robotoBold(size: 70))
                        .foregroundColor(viewModel.progressColor)
                        .overlay(
                            Text(viewModel.statusText)
                                .font(.robotoBold(size: 70))
                                .foregroundColor(viewModel.progressColor)
                                .blur(radius: 3)
                        )
                    
                    Text(viewModel.statusText)
                        .font(.robotoBold(size: 70))
                        .foregroundColor(settings.selectedBackground.color)
                }
                .compositingGroup()
                .opacity(viewModel.isRunning ? 1 : 0)
                
                Text(viewModel.timeString(from: viewModel.timeRemaining))
                    .font(.robotoLight(size: 32))
                    .foregroundColor(.white)
            }
            
            VStack {
                Spacer()
                
                Button(action: {
                    viewModel.startTimer()
                }) {
                    Image("play")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
                .opacity(viewModel.isRunning ? 0 : 1)
                .disabled(viewModel.isRunning)
                .padding(.bottom, 50)
            }
        }
        .withAppTheme()
    }
}

#Preview {
    TimerView()
        .withAppTheme()
}
