import Foundation

extension Date {
    var dayStart: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
