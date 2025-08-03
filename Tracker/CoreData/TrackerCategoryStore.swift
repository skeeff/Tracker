import Foundation
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerCategoryStoreProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func getCategoryName(at indexPath: IndexPath) -> String?
    func fetchCategories() throws
    func createCategory(name: String) throws
    func getCategoryCoreData(with name: String) throws -> TrackerCategoryCoreData?
    var delegate: TrackerCategoryStoreDelegate? { get set }
}

final class TrackerCategoryStore: NSObject, TrackerCategoryStoreProtocol {
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController : NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.name), ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    //MARK: Protocol methods
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func getCategoryName(at indexPath: IndexPath) -> String? {
        fetchedResultsController.object(at: indexPath).name
    }
    
    func fetchCategories() throws {
        try fetchedResultsController.performFetch()
    }
    
    func createCategory(name: String) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.id = UUID()
        categoryCoreData.name = name
        try context.save()
    }
    
    func getCategoryCoreData(with name: String) throws -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        let result = try context.fetch(request)
        return result.first
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
