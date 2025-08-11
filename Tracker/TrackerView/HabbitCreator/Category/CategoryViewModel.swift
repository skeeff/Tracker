import Foundation

protocol CategoryViewModelProtocol: AnyObject {
    var onDoneButtonStateChange: ((Bool) -> Void)? { get set }
    var onCategoriesUpdate: (() -> Void)? { get set }
    func categories() -> [TrackerCategory]
    func setCategory(category: TrackerCategory)
    func deleteCategory(category: String)
    func seletectedCategory(indexPath: IndexPath)
    func isSelected(indexPath: IndexPath) -> Bool
    func doneButtonTapped()
}

protocol CategoryViewModelDelegate: AnyObject {
    func category(_ category: String)
}

final class CategoryViewModel: CategoryViewModelProtocol {
    //MARK: Init
    init(dataProvider: DataProviderProtocol, selectedCategory: String?, newCategory: TrackerCategory) {
        self.dataProvider = dataProvider
        self.selectedCategory = selectedCategory
        self.newCategory = newCategory
        
        self.dataProvider?.delegate = self
    }
    
    
    //MARK: Properties
    weak var delegate: CategoryViewModelDelegate?
    
    var onDoneButtonStateChange: ((Bool) -> Void)?
    var onCategoriesUpdate: (() -> Void)?
    
    private var dataProvider: DataProviderProtocol?
    //    private var selectedCategory: String?
    private var newCategory: TrackerCategory?
    
    private var selectedCategory: String? {
        didSet {
            onCategoriesUpdate?()
            onDoneButtonStateChange?(selectedCategory != nil)
        }
    }
    //MARK: Methods
    func categories() -> [TrackerCategory]{
        dataProvider?.categories ?? []
    }
    
    func setCategory(category: TrackerCategory) {
        selectedCategory = category.category
        onCategoriesUpdate?()
    }
    
    func deleteCategory(category: String) {
        dataProvider?.deleteCategory(category)
    }
    
    
}
