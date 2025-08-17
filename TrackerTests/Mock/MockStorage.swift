@testable import Tracker
import CoreData
import Foundation
// MARK: - Mock TrackerStoreProtocol

final class MockTrackerStore: TrackerStoreProtocol {
    var tracker: Tracker?
    weak var delegate: TrackerStoreDelegate?

    func getTracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
        return tracker
    }

    func getTrackerCoreData(from tracker: Tracker) -> TrackerCoreData {
        return TrackerCoreData(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
    }

    func getTrackerFromCoreDataById(_ id: UUID) -> TrackerCoreData? {
        return nil
    }

    func createTracker(with tracker: Tracker) -> TrackerCoreData {
        return TrackerCoreData(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
    }
    
    // Методы-заглушки
    func deleteTracker(_ tracker: Tracker) {}
    func updateTracker(_ tracker: Tracker) {}
}

// MARK: - Mock TrackerCategoryStoreProtocol

final class MockTrackerCategoryStore: TrackerCategoryStoreProtocol {
    var categories: [TrackerCategory] = []
    weak var delegate: TrackerCategoryStoreDelegate?

    func createCategory(_ trackerCategory: TrackerCategory) {
        categories.append(trackerCategory)
    }
    
    func addTrackerToCategory(tracker: Tracker, category: String) {
        if let index = categories.firstIndex(where: { $0.category == category }) {
            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(tracker)
            categories[index] = TrackerCategory(category: category, trackers: updatedTrackers)
        }
        delegate?.didUpdateCategories(newCategories: categories)
    }
    
    // Методы-заглушки
    func deleteCategory(_ category: String) {}
}

// MARK: - Mock TrackerRecordStoreProtocol

final class MockTrackerRecordStore: TrackerRecordStoreProtocol {
    var completedRecords: Set<TrackerRecord> = []
    weak var delegate: TrackerRecordDelegate?

    func addRecord(forTrackerID trackerID: UUID, date: Date) throws {
        completedRecords.insert(TrackerRecord(id: trackerID, date: date))
        delegate?.didUpdateRecord()
    }
    
    func removeRecord(forTrackerID trackerID: UUID, date: Date) throws {
        completedRecords.remove(TrackerRecord(id: trackerID, date: date))
        delegate?.didUpdateRecord()
    }

    func isTrackerCompletedToday(trackerID: UUID, date: Date) throws -> Bool {
        return completedRecords.contains(where: {
            $0.id == trackerID && Calendar.current.isDate($0.date, inSameDayAs: date)
        })
    }

    func getCompletedCount(forTrackerID trackerID: UUID) throws -> Int {
        return completedRecords.filter({ $0.id == trackerID }).count
    }

    func getCompletedRecords() throws -> Set<TrackerRecord> {
        return completedRecords
    }
}


// MARK: - Mock DataProviderProtocol

final class MockDataProvider: DataProviderProtocol {
    var categories: [TrackerCategory] = []
    var completedRecords: Set<TrackerRecord> = []
    weak var delegate: DataProviderDelegate?

    init(categories: [TrackerCategory] = [], completedRecords: Set<TrackerRecord> = []) {
        self.categories = categories
        self.completedRecords = completedRecords
    }
    
    func getCategories(callback: @escaping () -> Void) {
        callback()
    }
    
    func getCompletedRecords() -> Set<TrackerRecord> {
        return completedRecords
    }
    
    func addRecord(forTrackerID trackerID: UUID, date: Date) {
        completedRecords.insert(TrackerRecord(id: trackerID, date: date))
        delegate?.didUpdate()
    }
    
    func deleteRecord(forTrackerID trackerID: UUID, date: Date) {
        completedRecords.remove(TrackerRecord(id: trackerID, date: date))
        delegate?.didUpdate()
    }
    
    // Методы-заглушки
    func addCategory(_ category: TrackerCategory) {}
    func addTrackertoCategory(_ traker: Tracker, _ category: String) {}
    func deleteCategory(_ name: String) {}
    func deleteTracker(_ tracker: Tracker) {}
    func updateTracker(_ tracker: Tracker) {}
    func getCompletedCount(for trackerID: UUID) -> Int { return 0 }
    func isTrackerCompletedToday(trackerID: UUID, date: Date) -> Bool { return false }
}
