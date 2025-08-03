import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func getTracker(at indexPath: IndexPath) -> Tracker?
    func getTrackerCategoryTitle(for section: Int) -> String?
    func fetchTrackers(forSelectedDate date: Date, withSearchText searchText: String?) throws
    func createTracker(name: String, emoji: String, color: UIColor, schedule: Set<Weekday>, categoryName: String) throws
    func deleteTracker(at indexPath: IndexPath) throws
    
    var delegate: TrackerStoreDelegate? { get set }
}

final class TrackerStore: NSObject, TrackerStoreProtocol {
    
    private let context: NSManagedObjectContext
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
        private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
            let request = TrackerCoreData.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "category.name", ascending: true),
                NSSortDescriptor(key: "name", ascending: true)
            ]
            let controller = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "category.name",
                cacheName: nil
            )
            controller.delegate = self
            return controller
        }()
//    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext, trackerCategoryStore: TrackerCategoryStoreProtocol) {
        self.context = context
        self.trackerCategoryStore = trackerCategoryStore
        super.init()
        
//        let request = TrackerCoreData.fetchRequest()
//        request.sortDescriptors = [
//            NSSortDescriptor(key: "category.name", ascending: true),
//            NSSortDescriptor(key: "name", ascending: true)
//        ]
//        
//        fetchedResultsController = NSFetchedResultsController(
//            fetchRequest: request,
//            managedObjectContext: context,
//            sectionNameKeyPath: "category.name",
//            cacheName: nil
//        )
//        fetchedResultsController.delegate = self
    }
    //MARK: Protocol methods
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func getTracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let emoji = trackerCoreData.emoji,
              let uiColor = trackerCoreData.uiColor,
                let schedule = trackerCoreData.scheduleSet else {
            return nil
        }
        return Tracker(id: id, name: name, emoji: emoji, color: uiColor, schedule: schedule)
    }
    
    func getTrackerCategoryTitle(for section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }
    
    func fetchTrackers(forSelectedDate date: Date, withSearchText searchText: String?) throws {
//        var predicates: [NSPredicate] = []
//          
//          let weekday = Weekday.from(date: date)
//          let weekdayNumber = weekday.rawValue
//          predicates.append(NSPredicate(format: "scheduleInts CONTAINS %d", weekdayNumber))
//          
//          if let searchText = searchText, !searchText.isEmpty {
//              predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
//          }
//          
//          // Создаем новый fetch request с теми же настройками
//          let request = TrackerCoreData.fetchRequest()
//          request.sortDescriptors = [
//              NSSortDescriptor(key: "category.name", ascending: true),
//              NSSortDescriptor(key: "name", ascending: true)
//          ]
//          
//          // Устанавливаем новый предикат
//          request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//          
//          // Обновляем fetch request у fetchedResultsController
//          fetchedResultsController = NSFetchedResultsController(
//              fetchRequest: request,
//              managedObjectContext: context,
//              sectionNameKeyPath: "category.name",
//              cacheName: nil
//          )
//          fetchedResultsController.delegate = self
//          
//          do {
//              try fetchedResultsController.performFetch()
//          } catch {
//              print("Failed to perform fetch: \(error)")
//              throw error
//          }

        
        var predicates: [NSPredicate] = []
        
        let weekday = Weekday.from(date: date)
        let weekdayNumber = weekday.rawValue
        predicates.append(NSPredicate(format: "scheduleInts CONTAINS %d", weekdayNumber))
        
        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
                try fetchedResultsController.performFetch()
            } catch {
                print("Failed to perform fetch: \(error)")
                // Добавьте здесь точку останова, чтобы увидеть, где происходит сбой
                throw error
            }
    }
    
    func createTracker(name: String, emoji: String, color: UIColor, schedule: Set<Weekday>, categoryName: String) throws {
        let categoryCoreData = try trackerCategoryStore.getCategoryCoreData(with: categoryName) ?? {
            try trackerCategoryStore.createCategory(name: categoryName)
            return try trackerCategoryStore.getCategoryCoreData(with: categoryName)!
        }()
        
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = UUID()
        trackerCoreData.name = name
        trackerCoreData.emoji = emoji
        
        // ✅ Присваиваем значения через обертки
        trackerCoreData.uiColor = color
        trackerCoreData.scheduleSet = schedule
        
        // ✅ Сохраняем расписание в виде массива Int для фильтрации
//        trackerCoreData.scheduleInts = Array(schedule.map { $0.rawValue }) as NSArray
        
        trackerCoreData.category = categoryCoreData
        
        try context.save()
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        context.delete(trackerCoreData)
        try context.save()
    }
    
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateTrackers()
    }
    
}
