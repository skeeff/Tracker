import Foundation

protocol CategoryViewModelProtocol: AnyObject {
    var delegate: CategoryViewModelDelegate? { get set }
    var onCategoriesUpdate: (() -> Void)? { get set }
    var onStateChange: (() -> Void)? { get set }
    var state: CategoryVCState { get }
    
    func categories() -> [TrackerCategory]
    func setSelectedCategory(at indexPath: IndexPath)
    func getSelectedCategory() -> String?
    func deleteCategory(at indexPath: IndexPath)
    func isSelected(at indexPath: IndexPath) -> Bool
    func didTapDoneButton(with newCategoryName: String)
    func didTapAddCategoryButton()
    func viewDidLoad()
    func didBeginEditing()
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
        self.dataProvider?.delegate = self
        
        if !dataProvider.categories.isEmpty {
            self.state = .choose
        } else {
            self.state = .onboarding
        }
    }
    
    //MARK: Properties
    
    weak var delegate: CategoryViewModelDelegate?
    
    var onCategoriesUpdate: (() -> Void)?
    var onStateChange: (() -> Void)?
    
    private(set) var state: CategoryVCState = .onboarding {
        didSet{
            onStateChange?()
        }
    }
    private var dataProvider: DataProviderProtocol?
    private var selectedCategory: String?
    
    //MARK: Methods
    func setState(_ state: CategoryVCState, callback: @escaping () -> Void) {
        self.state = state
        DispatchQueue.main.async(execute: callback)
    }
    
    func viewDidLoad(){
        updateState()
    }
    
    func didTapDoneButton(with newCategoryName: String) {
        if !newCategoryName.isEmpty {
            if !categories().contains(where: { $0.category == newCategoryName }) {
                dataProvider?.addCategory(TrackerCategory(category: newCategoryName, trackers: []))
//                onCategoriesUpdate?()
            }
        }
        selectedCategory = newCategoryName
        delegate?.category(selectedCategory ?? "")
        updateState()
        
        AnalyticsService.trackEvent(AnalyticsEvent(
                  event: .click,
                  screen: .categoryVC,
                  item: .selectedCategory)
              )
    }
    
    func didTapAddCategoryButton() {
        state = .create
        
        AnalyticsService.trackEvent(AnalyticsEvent(
            event: .click,
            screen: .categoryVC,
            item: .addedCategory)
        )
    }
    
    func isSelected(at indexPath: IndexPath) -> Bool {
        categories()[indexPath.row].category == selectedCategory
    }
    
    func categories() -> [TrackerCategory] {
        dataProvider?.categories ?? []
    }
        
    func getSelectedCategory() -> String? {
        selectedCategory
    }
    
    func setSelectedCategory(at indexPath: IndexPath) {
        let category = categories()[indexPath.row].category
        selectedCategory = category
        delegate?.category(selectedCategory ?? "")
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        let categoryName = categories()[indexPath.row].category
        dataProvider?.deleteCategory(categoryName)
    }
    func didBeginEditing() {
        self.state = .create
    }
    // MARK: - Private Methods
    private func updateState() {
        if categories().isEmpty {
            state = .onboarding
        } else {
            state = .choose
        }
    }
    
    private func tryToAddNewCategory(_ category: String) {
        guard !categories().contains(where: { $0.category == category }) else { return }
        dataProvider?.addCategory(TrackerCategory(category: category, trackers: []))
    }
    
    deinit {
        print("\(#function) view model")
    }
    
}

// MARK: - DataProviderDelegate
extension CategoryViewModel: DataProviderDelegate {
    func didUpdate() {
        updateState()
        onCategoriesUpdate?()
    }
}
