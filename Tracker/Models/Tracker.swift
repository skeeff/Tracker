import UIKit

enum Weekday: String, CaseIterable, Codable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var description: String {
        switch self {
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        case .monday: return "Понедельник"
        }
    }
    
    var shortDescription: String {
        switch self {
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        case .monday: return "Пн"
        }
    }
    
    var int: Int {
        switch self {
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        case .sunday: return 1
        }
    }
    
    func from(date: Date) -> Weekday {
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

struct Tracker: Identifiable {
    let id: UUID
    let name: String
    let emoji: String
    let color: UIColor
    let schedule: [Weekday]
    // daysCompleted и completedDates НЕ хранятся здесь.
    // Они будут вычисляться на основе массива TrackerRecord.
}

struct TrackerCategory {
    let category: String
    let trackers: [Tracker]
}

struct TrackerRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date

    func hash(into hasher: inout Hasher){
        hasher.combine(id)
        hasher.combine(date)
    }
    
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        return lhs.id == rhs.id && Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}

