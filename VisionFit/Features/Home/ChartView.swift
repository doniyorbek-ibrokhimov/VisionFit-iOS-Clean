import Charts
import SwiftUI

struct ChartView: View {
//    let data: [ChartData]
    let type: Metric

    @EnvironmentObject private var vm: HomeView.ViewModel
    // Time period selection
    @State private var selectedTimePeriod: TimePeriod = .week

    var body: some View {
        VStack {
            switch type {
            case .weight:
                chart(data: vm.weightData)
            case .height:
                chart(data: vm.heightData)
            case .calories:
                chart(data: vm.caloriesData)
            case .bmi:
                chart(data: vm.bmiData)
            }

            // Period selector
            HStack {
                ForEach(TimePeriod.allCases) { timePeriod in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedTimePeriod = timePeriod
                        }
                    }) {
                        Text(timePeriod.title)
                            .font(.system(size: 14, weight: selectedTimePeriod == timePeriod ? .medium : .regular))
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedTimePeriod == timePeriod ? Color.primaryDark : Color.clear)
                            )
                    }
                }
            }
            .padding(6)
            .background(Color.black)
            .cornerRadius(20)
            .padding(.bottom, 10)
        }
        .padding()
        .frame(height: UIScreen.main.bounds.height * 0.4)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.primaryDark)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        // non ui modifier
//         .onChange(of: vm.selectedMetric) { currentMetric, nextMetric in
// //            withAnimation(.easeInOut) {
                // let isCurrentBeforeNext = isCurrentMetricBeforeNext(currentMetric: currentMetric, nextMetric: nextMetric)
                // insertionEdge = isCurrentBeforeNext ? .trailing : .leading
                // removalEdge = isCurrentBeforeNext ? .leading : .trailing
//            }
//         }
//        .transition(
//            .asymmetric(
//                insertion:
//                        .move(edge: vm.insertionEdge)
//                        .combined(with: .opacity),
//                removal:
//                        .move(edge: vm.removalEdge)
//                        .combined(with: .opacity)
//            )
//        )
    }

    func chart(data: [ChartData]) -> some View {
        Chart {
            ForEach(data) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(vm.selectedMetric == type ? Color.primaryGreen : Color.white)
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel {
                    Group {
                        if let date = value.as(Date.self) {
                            switch selectedTimePeriod {
                            case .week:
                                Text(date, format: .dateTime.weekday(.abbreviated))
                            case .month:
                                Text(date, format: .dateTime.month(.abbreviated))
                            case .year:
                                Text(date, format: .dateTime.year())
                            // case .max:
                            //     Text(date, format: .dateTime)
                            //         .font(.system(size: 10))
                            //         .foregroundColor(.gray)
                            }
                        }
                    }
                    .font(.system(size: 10))
                    .foregroundColor(Color.white)
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                    .foregroundStyle(Color.white)

                AxisValueLabel {
                    if let weight = value.as(Double.self) {
                        Text("\(weight, specifier: "%.1f") \(type.measurement)")
                            .font(.system(size: 10))
                            .foregroundColor(Color.white)
                    }
                }
            }
        }
        .chartYScale(domain: type.domain(timePeriod: selectedTimePeriod))
        .transition(
            .asymmetric(
                insertion:
                        .move(edge: vm.insertionEdge)
//                        .combined(with: .opacity)
                ,
                removal:
                        .move(edge: vm.removalEdge)
//                        .combined(with: .opacity)
            )
        )
    }
}
