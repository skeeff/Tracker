import Foundation
import CoreData

protocol TrackerRecordDelegate: AnyObject {
    func didUpdateRecord()
}

protocol TrackerRecordStoreProtocol {
    func addRecord(forTrackerID trackerID: UUID, date: Date) throws
    func removeRecord(forTrackerID trackerID: UUID, date: Date) throws
    func isTrackerCompletedToday(trackerID: UUID, date: Date) throws -> Bool
    func getCompletedCount(forTrackerID trackerID: UUID) throws -> Int
    func getCompletedRecords() throws -> Set<TrackerRecord>
    var delegate: TrackerRecordDelegate? { get set }
}

final class TrackerRecordStore: NSObject, TrackerRecordStoreProtocol {
    
    private let context : NSManagedObjectContext
    
    weak var delegate: TrackerRecordDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    //MARK: Protocol methods
    func addRecord(forTrackerID trackerID: UUID, date: Date) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        
        let trackers = try context.fetch(fetchRequest)
        if let tracker = trackers.first {
            let recordCoreData = TrackerRecordCoreData(context: context)
            recordCoreData.id = UUID()
            recordCoreData.date = date
            recordCoreData.trackerOwner = tracker
            try context.save()
            delegate?.didUpdateRecord()
        }
        
    }
    
    func removeRecord(forTrackerID trackerID: UUID, date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(format: "trackerOwner.id == %@ AND date >= %@ AND date < %@", trackerID as CVarArg, startOfDay as CVarArg, endOfDay as CVarArg)
        let records = try context.fetch(request)
        if let recordToDelete = records.first {
            context.delete(recordToDelete)
            try context.save()
            delegate?.didUpdateRecord()
        }
        
    }
    
    func isTrackerCompletedToday(trackerID: UUID, date: Date) throws -> Bool {
        let request = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(format: "trackerOwner.id == %@ AND date >= %@ AND date < %@", trackerID as CVarArg, startOfDay as CVarArg, endOfDay as CVarArg)
        
        let count = try context.count(for: request)
        return count > 0
    }
    
    func getCompletedCount(forTrackerID trackerID: UUID) throws -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerOwner.id == %@", trackerID as CVarArg)
        
        return try context.count(for: request)
        
    }
    
    func getCompletedRecords() throws -> Set<TrackerRecord> {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let coreDataRecords = try context.fetch(request)
        
        let records = coreDataRecords.compactMap { coreDataRecord -> TrackerRecord? in
            guard let trackerID = coreDataRecord.trackerOwner?.id,
                  let recordDate = coreDataRecord.date else { return nil }
            return TrackerRecord(id: trackerID, date: recordDate)
        }
        return Set(records)
    }
}
