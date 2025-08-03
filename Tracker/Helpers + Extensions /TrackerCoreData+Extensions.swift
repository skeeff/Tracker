
import UIKit
//import CoreData

extension TrackerCoreData {

    var uiColor: UIColor? {
        get {
            guard let colorData = self.color else { return nil }
            guard let decodedColor = try? JSONDecoder().decode(CodableColor.self, from: colorData) else {
                return nil
            }
            return decodedColor.uiColor
        }
        set {
            guard let newColor = newValue else {
                self.color = nil
                return
            }
            let codableColor = CodableColor(color: newColor)
            self.color = try? JSONEncoder().encode(codableColor)
        }
    }

    var scheduleSet: Set<Weekday>? {
        get {
            guard let scheduleData = self.schedule else { return nil }
            return try? JSONDecoder().decode(Set<Weekday>.self, from: scheduleData)
        }
        set {
            guard let newSchedule = newValue else {
                self.schedule = nil
                return
            }
            self.schedule = try? JSONEncoder().encode(newSchedule)
        }
    }
}
