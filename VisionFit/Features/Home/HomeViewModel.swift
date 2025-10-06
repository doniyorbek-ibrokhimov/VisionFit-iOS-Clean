import SwiftUI

extension HomeView {
    final class ViewModel: ObservableObject {
        // MARK: - Selections
        @Published var selectedMetric: Metric = .weight
        @Published var insertionEdge: Edge = .trailing
        @Published var removalEdge: Edge = .leading
        
        func isCurrentMetricBeforeNext(currentMetric: Metric, nextMetric: Metric) -> Bool {
            let currentMetricIndex = Metric.allCases.firstIndex(of: currentMetric) ?? 0
            let nextMetricIndex = Metric.allCases.firstIndex(of: nextMetric) ?? 0
            
            return currentMetricIndex < nextMetricIndex
            // if currentMetricIndex < nextMetricIndex {
            //     return .trailing
            // } else {
            //     return .leading
            // }
        }

        // MARK: - Metrics Data
        @Published var weightData: [ChartData] = []
        @Published var heightData: [ChartData] = []
        @Published var caloriesData: [ChartData] = []
        @Published var bmiData: [ChartData] = []

        func getMetricData(type: Metric) {
            // Mock data
            switch type {
            case .weight:
                weightData = [
                    ChartData(day: 6, value: 75.3),
                    ChartData(day: 5, value: 74.8),
                    ChartData(day: 4, value: 76.2),
                    ChartData(day: 3, value: 75.5),
                    ChartData(day: 2, value: 76.8),
                    ChartData(day: 1, value: 75.9),
                    ChartData(day: 0, value: 74.8)
                ]
            case .height:
                heightData = [
                    ChartData(day: 6, value: 180.0),
                    ChartData(day: 5, value: 180.5),
                    ChartData(day: 4, value: 179.8),
                    ChartData(day: 3, value: 180.3),
                    ChartData(day: 2, value: 179.9),
                    ChartData(day: 1, value: 180.7),
                    ChartData(day: 0, value: 181.2)
                ]
            case .calories:
                caloriesData = [
                    ChartData(day: 6, value: 2100.0),
                    ChartData(day: 5, value: 1950.0),
                    ChartData(day: 4, value: 2250.0),
                    ChartData(day: 3, value: 2050.0),
                    ChartData(day: 2, value: 2300.0),
                    ChartData(day: 1, value: 1850.0),
                    ChartData(day: 0, value: 2150.0)
                ]
            case .bmi:
                bmiData = [
                    ChartData(day: 6, value: 25.8),
                    ChartData(day: 5, value: 25.2),
                    ChartData(day: 4, value: 26.1),
                    ChartData(day: 3, value: 25.4),
                    ChartData(day: 2, value: 26.3),
                    ChartData(day: 1, value: 25.7),
                    ChartData(day: 0, value: 24.9)
                ]
            }
        }
    }
}
