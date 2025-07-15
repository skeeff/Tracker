import UIKit
enum Weekday: Int, CaseIterable, CustomStringConvertible, Hashable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7
    
    
    var description: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    var shortDescription: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
    
    
    
    static func from(date: Date) -> Weekday {
            let calendar = Calendar.current
            // Calendar.current.component(.weekday, from: date) возвращает 1 для воскресенья, 2 для понедельника и т.д.
            // Нам нужно скорректировать это, чтобы соответствовать нашему enum (1 = понедельник).
            var weekdayComponent = calendar.component(.weekday, from: date)
            if weekdayComponent == 1 { // Воскресенье
                weekdayComponent = 7
            } else {
                weekdayComponent -= 1
            }
            return Weekday(rawValue: weekdayComponent)!
        }
}

struct Tracker {
    let id: Int
    let name: String
    let emoji: String
    let color: UIColor
    var daysCompleted: Int = 0
    let schedule: Set<Weekday>
    var isCompletedToday: Bool = false
    var completedDates: Set<Date> = []
}
