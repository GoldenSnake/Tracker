
import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let days: Set<Week>?
    
    init(name: String, color: UIColor, emoji: String, days: Set<Week>? = nil) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.emoji = emoji
        self.days = days
    }
}
