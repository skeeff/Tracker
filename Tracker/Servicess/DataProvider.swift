import Foundation

protocol DataProviderProtocol: AnyObject {
    var categories: [TrackerCategory] { get }
    func getCategories(callback: @escaping () -> Void)
    func addCategory(_ category: TrackerCategory)
    func addTrackertoCategory(_ traker: Tracker, _ category: String)
    func deleteCategory(_ name: String)
    func deleteTracker(_ tracker: Tracker)
    func addRecord(forTrackerID trackerID: UUID, date: Date)
    func deleteRecord(forTrackerID trackerID: UUID, date: Date)
    func getCompletedCount(for trackerID: UUID) -> Int
    func isTrackerCompletedToday(trackerID: UUID, date: Date) -> Bool
    func getCompletedRecords() -> Set<TrackerRecord>
}

final class DataProvider: DataProviderProtocol {
    
    private let categoryStore: TrackerCategoryStoreProtocol
    private let trackerStore: TrackerStoreProtocol
    private let recordStore: TrackerRecordStoreProtocol
    
    private(set) var categories: [TrackerCategory] = []
    
    init(
        categoryStore: TrackerCategoryStoreProtocol,
        trackerStore: TrackerStoreProtocol,
        recordStore: TrackerRecordStoreProtocol
    ) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        
        self.categories = categoryStore.categories
    }
    
    func getCategories(callback: @escaping () -> Void) {
        categories = categoryStore.categories
        callback()
    }
    
    func addCategory(_ category: TrackerCategory) {
        categoryStore.createCategory(category)
    }
    
    func addTrackertoCategory(_ traker: Tracker, _ category: String) {
        categoryStore.addTrackerToCategory(tracker: traker, category: category)
    }
    
    func deleteCategory(_ name: String) {
        categoryStore.deleteCategory(name)
    }
    
    func deleteTracker(_ tracker: Tracker) {
        trackerStore.deleteTracker(tracker)
    }
    
    func addRecord(forTrackerID trackerID: UUID, date: Date) {
        do {
            try recordStore.addRecord(forTrackerID: trackerID, date: date)
        } catch {
            print("Ошибка при добавлении записи: \(error)")
        }
    }
    
    func deleteRecord(forTrackerID trackerID: UUID, date: Date) {
        do {
            try recordStore.removeRecord(forTrackerID: trackerID, date: date)
        } catch {
            print("Ошибка при удалении записи: \(error)")
        }
    }
        
    func getCompletedCount(for trackerID: UUID) -> Int {
        do {
            return try recordStore.getCompletedCount(forTrackerID: trackerID)
        } catch {
            print("Ошибка при получении количества завершений: \(error)")
            return 0
        }
    }
    
    func isTrackerCompletedToday(trackerID: UUID, date: Date) -> Bool {
           do {
               return try recordStore.isTrackerCompletedToday(trackerID: trackerID, date: date)
           } catch {
               print("Ошибка при проверке завершенности: \(error)")
               return false
           }
       }
    func getCompletedRecords() -> Set<TrackerRecord> {
            do {
                return try recordStore.getCompletedRecords()
            } catch {
                print("Ошибка при получении всех записей: \(error)")
                return []
            }
        }
}
