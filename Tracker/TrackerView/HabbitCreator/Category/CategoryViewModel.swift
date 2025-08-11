import Foundation

protocol CategoryViewModelProtocol: AnyObject {
    var delegate: CategoryViewModelDelegate? { get set }
    var state: CategoryVCState { get }
    func setState(_ state: CategoryVCState, callback: @escaping () -> Void)
    func categories() -> [TrackerCategory]
    func setSelectedCategory(category: IndexPath, _ callback: @escaping () -> Void)
    func getSelectedCategory() -> String?
    func deleteCategory(category: String, _ callback: @escaping () -> Void)
    func isSelected(indexPath: IndexPath) -> Bool
    func didTapDoneButton(_ category: String, _ callback: @escaping () -> Void)
}

protocol CategoryViewModelDelegate: AnyObject {
    func category(_ category: String)
}

enum CategoryVCState {
    case onboarding
    case create
    case choose 
}

final class CategoryViewModel: CategoryViewModelProtocol {
    
    //MARK: Init
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
        
        if !dataProvider.categories.isEmpty {
            self.state = .choose
        } else {
            self.state = .onboarding
        }
    }
    
    //MARK: Properties
    
    weak var delegate: CategoryViewModelDelegate?
    
    private(set) var state: CategoryVCState = .onboarding
    private var dataProvider: DataProviderProtocol?
    private var selectedCategory: String?
    
    //MARK: Methods
    func setState(_ state: CategoryVCState, callback: @escaping () -> Void) {
        self.state = state
        DispatchQueue.main.async(execute: callback)
    }
    
    func didTapDoneButton(_ category: String, _ callback: @escaping () -> Void) {
        tryToAddNewCategory(category)
        callback()
    }
    
    func isSelected(indexPath: IndexPath) -> Bool {
        categories()[indexPath.row].category == selectedCategory
    }
    
    func categories() -> [TrackerCategory] {
        dataProvider?.categories ?? []
    }
    
    func setSelectedCategory(category: IndexPath, _ callback: @escaping () -> Void) {
        selectedCategory = categories()[category.row].category
        delegate?.category(selectedCategory ?? "")
        callback()
    }
    
    func getSelectedCategory() -> String? {
        selectedCategory
    }
    
    func deleteCategory(category: String, _ callback: @escaping () -> Void) {
        dataProvider?.deleteCategory(category)
        callback()
    }
    
    private func tryToAddNewCategory(_ category: String) {
        guard !categories().contains(where: { $0.category == category }) else { return }
        dataProvider?.addCategory(TrackerCategory(category: category, trackers: []))
    }
    
    deinit {
        print("\(#function) view model")
    }
    
}
