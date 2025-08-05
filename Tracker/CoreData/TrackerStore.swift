import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTracker()
}

protocol TrackerStoreProtocol {
    func getTracker(from trackerCoreData: TrackerCoreData) -> Tracker?
    func getTrackerCoreData(from tracker: Tracker) -> TrackerCoreData
    func getTrackerFromCoreDataById(_ id: UUID) -> TrackerCoreData?
    func createTracker(with tracker: Tracker) -> TrackerCoreData
    func deleteTracker(_ tracker: Tracker)
    var delegate: TrackerStoreDelegate? { get set }
}

final class TrackerStore: NSObject, TrackerStoreProtocol {
    
    private let context: NSManagedObjectContext
    private let appDelegate: AppDelegate
    private let uiColorMarshalling = UIColorMarshalling.shared
    
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext, appDelegate: AppDelegate) {
        self.context = context
        self.appDelegate = appDelegate
        super.init()
    }
    //MARK: Protocol methods
    
    func getTracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
        
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let emoji = trackerCoreData.emoji,
              let uiColor = trackerCoreData.color,
              let schedule = trackerCoreData.schedule as? [Weekday] else {
            return nil
        }
        
        return Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: uiColorMarshalling.color(from: uiColor),
            schedule: schedule
        )
    }
    
    func getTrackerCoreData(from tracker: Tracker) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule as NSObject
        return trackerCoreData
    }
    
    func getTrackerFromCoreDataById(_ id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching tracker by id: \(error)")
            return nil
        }
    }
    
    func createTracker(with tracker: Tracker) -> TrackerCoreData {
        print(#function)
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji

        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.schedule = tracker.schedule as NSObject
        
        return trackerCoreData
    }
    
    func deleteTracker(_ tracker: Tracker) {
        guard let trackerCoreData = getTrackerFromCoreDataById(tracker.id) else { return }
        context.delete(trackerCoreData)
        appDelegate.saveContext()
        delegate?.didUpdateTracker()
    }
    
}
