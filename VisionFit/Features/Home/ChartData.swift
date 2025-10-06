import Foundation

struct ChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    
    init(day: Int, value: Double) {
        let calendar: Calendar = Calendar.current
        self.date = calendar.date(byAdding: .day, value: -day, to: Date()) ?? Date()
        self.value = value
    }
}
