import UIKit
enum Weekday: Int, CaseIterable, CustomStringConvertible, Hashable, Codable {
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
        let components = calendar.dateComponents([.weekday], from: date)
        switch components.weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .sunday
        }
    }
}

struct CodableColor: Codable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    init(color: UIColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
    }
    
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

struct Tracker: Identifiable, Codable {
    let id: UUID
    let name: String
    let emoji: String
    let color: CodableColor
    let schedule: Set<Weekday>
    // daysCompleted и completedDates НЕ хранятся здесь.
    // Они будут вычисляться на основе массива TrackerRecord.
    
    init(id: UUID = UUID(), name: String, emoji: String, color: UIColor, schedule: Set<Weekday>) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = CodableColor(color: color)
        self.schedule = schedule
    }
}

struct TrackerCategory: Identifiable, Codable {
    let id: UUID
    let category: String
    let trackers: [Tracker]
    
    init(id: UUID = UUID(), category: String, trackers: [Tracker]) {
        self.id = id
        self.category = category
        self.trackers = trackers
    }
}

struct TrackerRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    
    init(id: UUID, date: Date) {
        self.id = id
        self.date = date
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
        hasher.combine(date)
    }
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        return lhs.id == rhs.id && Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}
