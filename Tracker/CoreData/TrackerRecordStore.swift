import Foundation
import CoreData

protocol TrackerRecordStoreProtocol {
    func addRecord(forTrackerID trackerID: UUID, date: Date) throws
    func removeRecord(forTrackerID trackerID: UUID, date: Date) throws
    func isTrackerCompletedToday(trackerID: UUID, date: Date) throws -> Bool
    func getCompletedCount(forTrackerID trackerID: UUID) throws -> Int
}

final class TrackerRecordStore: NSObject, TrackerRecordStoreProtocol {
    
    private let context : NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    //MARK: Protocol methods
    func addRecord(forTrackerID trackerID: UUID, date: Date) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = trackerID
        recordCoreData.date = date
        try context.save()
    }
    
    func removeRecord(forTrackerID trackerID: UUID, date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(format: "id == %@ AND date >= %@ AND date < %@", trackerID as CVarArg, startOfDay as CVarArg, endOfDay as CVarArg)
        let records = try context.fetch(request)
        if let recordToDelete = records.first {
            context.delete(recordToDelete)
            try context.save()
        }
    }
    
    func isTrackerCompletedToday(trackerID: UUID, date: Date) throws -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(format: "id == %@ AND date >= %@ AND date < %@", trackerID as CVarArg, startOfDay as CVarArg, endOfDay as CVarArg)
        
        let count = try context.count(for: request)
        return count > 0
    }
    
    func getCompletedCount(forTrackerID trackerID: UUID) throws -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        
        return try context.count(for: request)
    }
    
}
