import Foundation

extension DateFormatter{
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        formatter.dateFormat = "dd.mm.yyyy"
        return formatter
    }()
}
