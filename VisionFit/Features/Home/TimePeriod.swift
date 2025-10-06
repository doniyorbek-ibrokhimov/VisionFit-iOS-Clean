import Foundation

enum TimePeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case year
    // case max

    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .week:
            return "Weekly"
        case .month:
            return "Monthly"
        case .year:
            return "Yearly"
        // case .max:
        //     return "Max"
        }
    }
}   
