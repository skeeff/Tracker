import Foundation

protocol DataProviderProtocol: AnyObject {
    var categories: [TrackerCategory] { get }
    func getCategories(callback: @escaping () -> Void)
    func addCategory(_ category: TrackerCategory)
    func addTrackertoCategory(_ traker: Tracker, _ category: String)
    func deleteCategory(_ name: String)
    func deleteTracker(_ tracker: Tracker)
}

final class DataProvider: DataProviderProtocol {
    
    private let categoryStore: TrackerCategoryStoreProtocol
    private let trackerStore: TrackerStoreProtocol
    
    private(set) var categories: [TrackerCategory] = []
    
    init(
        categoryStore: TrackerCategoryStoreProtocol,
        trackerStore: TrackerStoreProtocol
    ) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        
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
}
