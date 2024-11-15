
import Foundation

func convertDaysToString(days: Set<Weekday>?) -> String? {
    guard let days = days else { return nil }
    return days.map { String($0.rawValue) }.joined(separator: ",")
}


func convertStringToDays(daysString: String?) -> Set<Weekday>? {
    guard let daysString = daysString else { return Set() }
    
    let dayNumbers = daysString.split(separator: ",").compactMap { Int($0) }
    let daysSet = Set(dayNumbers.compactMap { Weekday(rawValue: $0) })
    
    return daysSet
}
