import UIKit
import CoreData

protocol TrackerCategoryStoreProtocol {
    var categories: [TrackerCategory] { get }
    func createCategory(_ trackerCategory: TrackerCategory)
    func addTrackerToCategory(tracker: Tracker, category: String)
    func deleteCategory(_ category: String)
}

final class TrackerCategoryStore: NSObject, TrackerCategoryStoreProtocol {
    private let context: NSManagedObjectContext
    private let appDelegate: AppDelegate
    private let trackerStore: TrackerStoreProtocol
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name,
                                                         ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
//        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching TrackerCategoryCoreData: \(error)")
        }
        
        return fetchedResultsController
    }()
    
    var categories: [TrackerCategory] {
        guard let categoriesCoreData = fetchedResultsController.fetchedObjects else { return [] }
        return categoriesCoreData.compactMap { getCategory(from: $0)}
    }
    
    init(context: NSManagedObjectContext, appDelegate: AppDelegate, trackerStore: TrackerStoreProtocol) {
        self.context = context
        self.appDelegate = appDelegate
        self.trackerStore = trackerStore
        super.init()
    }
    
    convenience init(trackerStore: TrackerStoreProtocol) {
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        else {
            assertionFailure("AppDelegate not found")
            self.init(trackerStore: trackerStore)
            return
        }
        
        self.init(
            context: appDelegate.persistentContainer.viewContext,
            appDelegate: appDelegate,
            trackerStore: trackerStore
        )
    }

    //MARK: Protocol methods
    func createCategory(_ trackerCategory: TrackerCategory) {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.name = trackerCategory.category
        categoryCoreData.trackers = NSSet(array: trackerCategory.trackers)
        appDelegate.saveContext()
    }
    
    func addTrackerToCategory(tracker: Tracker, category: String) {
        print(#function)
        let trackerCoreData = trackerStore.createTracker(with: tracker)
        trackerCoreData.lastCategory = category
        guard
            let category = getCategoryCoreData(from: category),
            let trackers = category.trackers as? Set<TrackerCoreData>
        else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = category
            newCategory.trackers = NSSet(array: [trackerCoreData])
            appDelegate.saveContext()
            return
        }
        category.trackers = trackers.union([trackerCoreData]) as NSSet
        appDelegate.saveContext()
    }
    
    func deleteCategory(_ category: String) {
        guard let trackerCategoryCoreData = getCategoryCoreData(from: category) else { return }
        context.delete(trackerCategoryCoreData)
        appDelegate.saveContext()
    }
    
    //MARK: - private methods
    
    private func getCategory(from categoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard
            let name = categoryCoreData.name,
            let trackers = categoryCoreData.trackers as? Set<TrackerCoreData>
        else { return nil }
        
        return TrackerCategory(
            category: name,
            trackers: trackers.compactMap { trackerStore.getTracker(from: $0) }
        )
    }
    
    private func getCategoryCoreData(from category: String) -> TrackerCategoryCoreData? {
        let request = fetchedResultsController.fetchRequest
        request.predicate = NSPredicate(format: "name == %@", category as CVarArg)
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching TrackerCategoryCoreData: \(error)")
            return nil
        }
    }
}
