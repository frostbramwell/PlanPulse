import SwiftUI

class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int
    @Published var isRunning: Bool = false
    @Published var isWorkSession: Bool = true
    
    private let workTime: Int = 25 * 60
    private let relaxTime: Int = 5 * 60
    private var timer: Timer?
    
    init() {
        self.timeRemaining = workTime
    }
    
    var progress: CGFloat {
        let totalTime = isWorkSession ? workTime : relaxTime
        return 1.0 - CGFloat(timeRemaining) / CGFloat(totalTime)
    }
    
    var progressColor: Color {
        isWorkSession ? Color.green : Color(red: 255/255, green: 189/255, blue: 82/255, opacity: 1)
    }
    
    var statusText: String {
        isWorkSession ? "Work" : "Relax"
    }
    
    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.switchSession()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    private func switchSession() {
        isWorkSession.toggle()
        timeRemaining = isWorkSession ? workTime : relaxTime
    }
    
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
} 