import SwiftUI

struct Wave: View {
    @State private var phase: CGFloat = 0
    @State private var tiltPhase: CGFloat = 0
    @State private var riseProgress: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let radius = min(width, height) / 2
                
                let clipRect = CGRect(x: 1, y: 1, width: width - 2, height: height - 2)
                context.clip(to: Path(ellipseIn: clipRect))
                
                let startY = height + 50
                let endY = -height
                let currentY = startY + (endY - startY) * riseProgress
                
                context.translateBy(x: 0, y: currentY)
                
                let currentTilt = sin(tiltPhase) * 30.0
                
                var fillPath = Path()
                fillPath.move(to: CGPoint(x: 0, y: height * 2))
                fillPath.addLine(to: CGPoint(x: 0, y: 0))
                
                stride(from: 0, through: width, by: 1).forEach { x in
                    let relativeX = x / width
                    let centerEffect = sin(.pi * relativeX) * 8
                    let y = (sin(relativeX * 4 * .pi + phase) * 9) + centerEffect
                    let tilt = (x / width - 0.5) * currentTilt
                    fillPath.addLine(to: CGPoint(x: x, y: y + tilt))
                }
                
                fillPath.addLine(to: CGPoint(x: width, y: height * 2))
                fillPath.closeSubpath()
                
                context.fill(fillPath, with: .color(Color(red: 44/255, green: 110/255, blue: 3/255)))
                
                var linePath = Path()
                linePath.move(to: CGPoint(x: 0, y: 0))
                stride(from: 0, through: width, by: 1).forEach { x in
                    let relativeX = x / width
                    let centerEffect = sin(.pi * relativeX) * 8
                    let y = (sin(relativeX * 4 * .pi + phase) * 9) + centerEffect
                    let tilt = (x / width - 0.5) * currentTilt
                    linePath.addLine(to: CGPoint(x: x, y: y + tilt))
                }
                
                context.stroke(linePath, with: .color(Color(red: 44/255, green: 110/255, blue: 3/255)), lineWidth: 2)
                
                var mirrorFillPath = Path()
                mirrorFillPath.move(to: CGPoint(x: width, y: height * 2))
                mirrorFillPath.addLine(to: CGPoint(x: width, y: 0))
                
                stride(from: 0, through: width, by: 1).forEach { x in
                    let relativeX = (width - x) / width
                    let centerEffect = sin(.pi * relativeX) * 8
                    let rightBend = pow(relativeX - 1, 2) * 13
                    let y = (sin(relativeX * 4 * .pi - phase) * 9) + centerEffect + rightBend
                    let tilt = (x / width - 0.5) * currentTilt
                    mirrorFillPath.addLine(to: CGPoint(x: width - x, y: y + tilt))
                }
                
                mirrorFillPath.addLine(to: CGPoint(x: 0, y: height * 2))
                mirrorFillPath.closeSubpath()
                
                context.fill(mirrorFillPath, with: .color(Color(red: 119/255, green: 255/255, blue: 35/255)))
                
                var mirrorLinePath = Path()
                mirrorLinePath.move(to: CGPoint(x: width, y: 0))
                stride(from: 0, through: width, by: 1).forEach { x in
                    let relativeX = (width - x) / width
                    let centerEffect = sin(.pi * relativeX) * 8
                    let rightBend = pow(relativeX - 1, 2) * 13
                    let y = (sin(relativeX * 4 * .pi - phase) * 9) + centerEffect + rightBend
                    let tilt = (x / width - 0.5) * currentTilt
                    mirrorLinePath.addLine(to: CGPoint(x: width - x, y: y + tilt))
                }
                
                context.stroke(mirrorLinePath, with: .color(Color(red: 119/255, green: 255/255, blue: 35/255)), lineWidth: 2)
                
                context.translateBy(x: 0, y: -currentY)
                
                let circlePath = Path(ellipseIn: CGRect(x: 0, y: 0, width: width, height: height))
                context.stroke(circlePath, with: .color(.gray.opacity(0.5)), lineWidth: 4)
            }
            .onChange(of: timeline.date) { _ in
                withAnimation(.linear(duration: 0.01)) {
                    phase -= 0.05
                    tiltPhase += 0.06
                    
                    if riseProgress < 1.0 {
                        riseProgress += 0.004 
                    }
                }
            }
        }
    }
}

struct LaunchScreenView: View {
    @StateObject private var settings = SettingsViewModel.shared
    @State private var isActive = false
    @State private var dotCount = 0
    
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            settings.selectedBackground.color
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                Wave()
                    .frame(width: 300, height: 300)
                
                Text("Loading" + String(repeating: ".", count: dotCount))
                    .font(.robotoLight(size: 60))
                    .foregroundColor(.white)
            }
            .offset(y: -50)
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }
}

#Preview {
    LaunchScreenView()
} 
