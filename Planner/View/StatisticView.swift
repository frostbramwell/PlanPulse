import SwiftUI
import CoreData

enum StatisticPeriod: String, CaseIterable, Identifiable {
    case week = "W"
    case month = "M"
    case halfYear = "6M"
    case year = "Y"
    
    var id: String { self.rawValue }
}

struct StatisticData: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let count: Int
    
    static func == (lhs: StatisticData, rhs: StatisticData) -> Bool {
        lhs.label == rhs.label && lhs.count == rhs.count
    }
}

struct StatisticView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: StatisticViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: StatisticViewModel(viewContext: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(spacing: 25) {
                Text("Statistics")
                    .font(.robotoBold(size: 24))
                    .padding(.top, 30)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 40)
                    
                    HStack(spacing: 0) {
                        ForEach(StatisticPeriod.allCases) { period in
                            Button(action: {
                                viewModel.selectedPeriod = period
                            }) {
                                Text(period.rawValue)
                                    .font(.robotoMedium(size: 14))
                                    .fontWeight(viewModel.selectedPeriod == period ? .bold : .regular)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 30)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(viewModel.selectedPeriod == period ? Color.white : Color.clear)
                                    )
                                    .foregroundColor(viewModel.selectedPeriod == period ? .black : .white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(height: 40)
                .padding(.horizontal)
                .onChange(of: viewModel.selectedPeriod) { _ in
                    viewModel.updateStatistics()
                }
            }
            
            Spacer()
            
            if viewModel.statisticsData.isEmpty {
                VStack {
                    Text("No data to display")
                        .font(.robotoRegular(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
            } else {
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .bottom, spacing: 15) {
                            ForEach(viewModel.statisticsData) { data in
                                BarView(data: data, maxValue: viewModel.maxCountValue())
                            }
                        }
                        .frame(minWidth: geometry.size.width, alignment: .center)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .animation(.spring(), value: viewModel.statisticsData)
                    }
                }
                .frame(height: 250)
                .padding(.bottom, 175)
            }
        }
        .onAppear {
            viewModel.updateStatistics()
        }
    }
}

struct BarView: View {
    let data: StatisticData
    let maxValue: Int
    
    private var barHeight: CGFloat {
        let height = CGFloat(data.count) / CGFloat(maxValue) * 200
        return max(height, data.count > 0 ? 20 : 0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color(red: 32/255, green: 64/255, blue: 87/255, opacity: 1))
                        .cornerRadius(15, corners: [.topLeft, .topRight])
                        .frame(width: 30, height: barHeight)
                    
                    if data.count > 0 {
                        Text("\(data.count)")
                            .font(.robotoLight(size: 16))
                            .foregroundColor(.white)
                            .padding(.top, 5)
                    }
                }
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 30, height: 1)
                .padding(.vertical, 2)
            
            Text(data.label)
                .font(.robotoRegular(size: 12))
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    StatisticView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
