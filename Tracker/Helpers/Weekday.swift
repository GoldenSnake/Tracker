import Foundation

enum Weekday: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    // Полное имя дня недели
    var name: String {
        switch self {
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        case .sunday:
            return "Воскресенье"
        }
    }
    
    // Короткое имя дня недели
    var shortName: String {
        switch self {
        case .monday:
            return "Пн."
        case .tuesday:
            return "Вт."
        case .wednesday:
            return "Ср."
        case .thursday:
            return "Чт."
        case .friday:
            return "Пт."
        case .saturday:
            return "Сб."
        case .sunday:
            return "Вс."
        }
    }
    
    init(date: Date) {
        self = Weekday(rawValue: Calendar.current.component(.weekday, from: date)) ?? .monday
    }
}
