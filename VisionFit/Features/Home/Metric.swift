import SwiftUI

enum Metric: String, CaseIterable, Identifiable {
    case weight
    case height
    case calories
    case bmi

    var id: String { self.rawValue }

    var icon: Image {
        switch self {
        case .weight: return Image(systemName: "scalemass")
        case .height: return Image(systemName: "ruler")
        case .calories: return Image(systemName: "flame")
        case .bmi: return Image(systemName: "person.3")
        }
    }

    var measurement: String {
        switch self {
        case .weight: return "kg"
        case .height: return "cm"
        case .calories: return "cal"
        case .bmi: return "bmi"
        }
    }

    var value: String {
        switch self {
        case .weight: return "75.2 \(measurement)"
        case .height: return "180 \(measurement)"
        case .calories: return "2500 \(measurement)"
        case .bmi: return "24.2 \(measurement)"
        }
    }

    func domain(timePeriod: TimePeriod) -> ClosedRange<Double> {
        switch self {
        case .weight: return 40...120
        case .height: return 140...220
        case .calories:
            switch timePeriod {
            case .week: return 1000...3000
            case .month: return 1000...3000
            case .year: return 1000...3000
            }
        case .bmi:
            switch timePeriod {
            case .week: return 18.5...40
            case .month: return 18.5...40
            case .year: return 18.5...40
            }
        }
    }
}
