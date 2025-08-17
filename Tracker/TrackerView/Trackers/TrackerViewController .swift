import UIKit

final class TrackerViewController: UIViewController{
    //MARK: Properties
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedRecords: Set<TrackerRecord> = []
    private let dateFormatter = DateFormatter()
    private let calendar = Calendar.current
    private var currentDate = Date()
    
    private var currentFilter: Filter?
    
    private var isSearch: Bool = false
    
    private let dataProvider: DataProviderProtocol
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.layer.cornerRadius = 8
        datePicker.layer.masksToBounds = true
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = .current
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalToConstant: 110).isActive = true
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(
            TrackerCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCollectionViewHeader.reuseIdentifier
        )
        return collectionView
    }()
    
    //MARK: UI
    private lazy var placeholderImageView: UIImageView = {
        let temporaryImage = UIImage(named: "trackers_placeholder")
        let temporaryImageView = UIImageView(image: temporaryImage)
        temporaryImageView.translatesAutoresizingMaskIntoConstraints = false
        return temporaryImageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let temporaryLabel = UILabel()
        temporaryLabel.text = NSLocalizedString("what_to_track", comment: "")
        temporaryLabel.font = .systemFont(ofSize: 12, weight: .medium)
        temporaryLabel.textColor = .black
        temporaryLabel.translatesAutoresizingMaskIntoConstraints = false
        return temporaryLabel
    }()
    
    private lazy var trackersLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers",comment: "")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = NSLocalizedString("search", comment: "")
        searchController.searchBar.layer.cornerRadius = 8
        searchController.searchBar.clipsToBounds = true
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchController.delegate = self
        return searchController
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitle(NSLocalizedString("filter_title", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        return button
    }()
    
    init(
        dataProvider: DataProviderProtocol
    ) {
        self.dataProvider = dataProvider
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupUI()
        configureFilterButton()
        setupInitialData()
        dataProvider.delegate = self
        reloadData()
    
//        dataProvider.getCategories() { [weak self] in
//            guard let self else { return }
//            DispatchQueue.main.async {
//                self.categories = self.dataProvider.categories
//                self.filterTrackersBySelectedDate(self.datePicker)
//                self.updatePlaceholderVisibility()
//                self.collectionView.reloadData()
//                //                print("ALL \(self.categories)")
//                //                print("VISIBLE \(self.visibleCategories)")
//            }
//        }
    }
    
    private func setupUI(){
        
        view.addSubview(placeholderLabel)
        view.addSubview(placeholderImageView)
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 302),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8)
        ])
        
        view.addSubview(collectionView)
        let filterButtonHeight: CGFloat = 50.0 
        let bottomPadding: CGFloat = 16.0
        
        let totalBottomInset = filterButtonHeight + bottomPadding
        
        collectionView.contentInset.bottom = totalBottomInset
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    
    private func setupNavigationController() {
        navigationItem.title = trackersLabel.text
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.searchController = searchController
        navigationItem.searchController?.searchBar.tintColor = .label
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func configureFilterButton() {
        view.addSubview(filterButton)
        
        NSLayoutConstraint.activate([
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: -16),
            filterButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                  constant: 131),
            filterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -131),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func updatePlaceholderVisibility(){
        if visibleCategories.isEmpty {
            placeholderImageView.image = UIImage(named: "trackers_placeholder")
            placeholderLabel.text = NSLocalizedString("what_to_track", comment: "")
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    private func setupInitialData(){
        self.categories = dataProvider.categories
        self.completedRecords = dataProvider.getCompletedRecords()
        self.filterTrackersBySelectedDate(datePicker)
        self.collectionView.reloadData()
        self.updatePlaceholderVisibility()
    }
    
    // context
    private func showDeleteConfirmation(for tracker: Tracker) {
        let alert = UIAlertController(
            title: NSLocalizedString("delete_tracker", comment: ""),
            message: NSLocalizedString("delete_tracker_message", comment: ""),
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete", comment: ""),
            style: .destructive
        ) { [weak self] _ in
            self?.dataProvider.deleteTracker(tracker)
            self?.reloadData()
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    //filter
    private func toggleFilterButtonVisibility() {
        if visibleCategories.isEmpty {
            filterButton.isHidden = true
        } else {
            filterButton.isHidden = false
        }
    }
    
    private func filterTrackersBySelectedDate(_ sender: UIDatePicker) {
        currentDate = calendar.date(from: sender.date)
        let weekDay = calendar.component(.weekday, from: currentDate)
        var visibleCategories: [TrackerCategory] = []
        categories.forEach { category in
            var trackers: [Tracker] = []
            category.trackers.forEach { tracker in
                guard tracker.schedule.isEmpty,
                      !completedRecords.contains(where: {
                          $0.id == tracker.id &&
                          $0.date != currentDate})
                else {
                    tracker.schedule.forEach { schedule in
                        if schedule.int == weekDay {
                            trackers.append(tracker)
                        }
                    }
                    return
                }
                trackers.append(tracker)
            }
            let visibleCategory: TrackerCategory = TrackerCategory(category: category.category, trackers: trackers)
            if !visibleCategory.trackers.isEmpty {
                visibleCategories.append(visibleCategory)
            }
        }
        self.visibleCategories = visibleCategories
    }
    
    private func setFilter() {
        switch currentFilter {
        case .all:
            allTrackersFilter()
        case .today:
            trackersForTodayFilter()
        case .complete:
            completedTrackersFilter()
        case .incomplete:
            incompleteTrackersFilter()
        case nil:
            allTrackersFilter()
        }
    }
    
    private func todaysTrackers() {
        filterTrackersBySelectedDate(datePicker)
        collectionView.reloadData()
    }
    private func isCompleted(_ tracker: Tracker) -> Bool {
        completedRecords.contains { record in
            let daysMatch = Calendar.current.isDate(record.date, inSameDayAs: datePicker.date)
            return record.id == tracker.id && daysMatch
        }
    }
    
    
    //MARK: objc
    @objc
    private func addButtonTapped(){
        let habbitCreatorVC = HabbitCreatorViewController(dataProvider: dataProvider)
        habbitCreatorVC.modalPresentationStyle = .pageSheet
        habbitCreatorVC.modalTransitionStyle = .coverVertical
        habbitCreatorVC.delegate = self
        present(habbitCreatorVC, animated: true)
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        reloadData()
        filterTrackersBySelectedDate(sender)
        setFilter()
        toggleFilterButtonVisibility()
        collectionView.reloadData()
    }
    
    @objc
    private func didTapFilterButton() {
        
        let viewModel = FilterViewModel(selectedFilter: self.currentFilter)
        viewModel.delegate = self
        
        let filterVC = FilterViewController(
            viewModel: viewModel
        )
        
        let filterNC = UINavigationController(rootViewController: filterVC)
        
        filterNC.modalPresentationStyle = .popover
        present(filterNC, animated: true)
    }
}
// MARK: Extensions
extension TrackerViewController:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            fatalError("Failed to dequeue TrackerCell")
        }
        
        cell.delegate = self
        
        let isCompleted = completedRecords.contains(where: {
            $0.id == visibleCategories[indexPath.section].trackers[indexPath.row].id &&
            calendar.numberOfDaysBetween($0.date, and: currentDate) == 0})
        let daysCompleted = completedRecords.filter({$0.id == visibleCategories[indexPath.section].trackers[indexPath.row].id}).count
        
        cell.configure(
            with: visibleCategories[indexPath.section].trackers[indexPath.row],
            isCompletedForSelectedDate: isCompleted,
            daysCompleted: daysCompleted
        )
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let header: UICollectionReusableView
        
        if #available(iOS 18.0, *) {
            return CGSize(width: collectionView.bounds.width - 56, height: 18)
        } else {
            header = self.collectionView(
                collectionView,
                viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                at: indexPath
            )
        }
        
        
        
        return header.systemLayoutSizeFitting(CGSize(
            width: collectionView.frame.width,
            height: UIView.layoutFittingExpandedSize.height),
                                              withHorizontalFittingPriority: .required,
                                              verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCollectionViewHeader.reuseIdentifier,
            for: indexPath
        ) as? TrackerCollectionViewHeader else { return UICollectionReusableView() }
        
        header.configureHeader(categories: visibleCategories, indexPath: indexPath)
        
        return header
    }
}

extension TrackerViewController: TrackerCellDelegate {
    
    func toggleCompleteButton(isCompleted: Bool, for trackerID: UUID, completion: @escaping () -> Void) {
        guard currentDate <= Date() else {
            return
        }
        
        if isCompleted {
            dataProvider.deleteRecord(forTrackerID: trackerID, date: currentDate)
        } else {
            dataProvider.addRecord(forTrackerID: trackerID, date: currentDate)
        }
        
        reloadData()
        completion()
        
    }
    
    func editTracker(_ tracker: Tracker) {
        // Find the category for this tracker
        let category = findCategoryForTracker(tracker)
        
        let habbitCreatorVC = HabbitCreatorViewController(dataProvider: dataProvider, trackerToEdit: tracker)
        habbitCreatorVC.modalPresentationStyle = .pageSheet
        habbitCreatorVC.modalTransitionStyle = .coverVertical
        habbitCreatorVC.delegate = self
        habbitCreatorVC.configureForEditing(tracker: tracker, category: category)
        present(habbitCreatorVC, animated: true)
    }
    
    private func findCategoryForTracker(_ tracker: Tracker) -> String {
        for category in categories {
            if category.trackers.contains(where: { $0.id == tracker.id }) {
                return category.category
            }
        }
        return ""
    }
    
    func deleteTracker(_ tracker: Tracker) {
        showDeleteConfirmation(for: tracker)
    }
    
    private func reloadData() {
        dataProvider.getCategories() { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.categories = self.dataProvider.categories
                
                self.completedRecords = self.dataProvider.getCompletedRecords()
                self.filterTrackersBySelectedDate(self.datePicker)
                self.collectionView.reloadData()
                self.updatePlaceholderVisibility()
                
            }
        }
    }
}

extension TrackerViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        
        isSearch = true
        collectionView.reloadData()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        
        
        datePickerValueChanged(datePicker)
        isSearch = false
        collectionView.reloadData()
    }
}

extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        isSearch = true
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            let searchTerms = searchText.lowercased().components(separatedBy: " ")
            
            visibleCategories = categories.compactMap { category in
                let categoryMatches = searchTerms.contains { term in
                    category.category.lowercased().contains(term)
                }
                
                let filteredTrackers = category.trackers.filter { tracker in
                    searchTerms.contains { term in
                        tracker.name.lowercased().contains(term)
                    }
                }
                
                if categoryMatches || !filteredTrackers.isEmpty {
                    if categoryMatches {
                        return TrackerCategory(
                            category: category.category,
                            trackers: category.trackers
                        )
                    } else {
                        return TrackerCategory(
                            category: category.category,
                            trackers: filteredTrackers
                        )
                    }
                }
                return nil
            }
            collectionView.reloadData()
        } else {
            visibleCategories = categories
            datePickerValueChanged(datePicker)
        }
    }
}

extension TrackerViewController: FilterDelegate {
    func updateFilter(filter: Filter) {
        self.currentFilter = filter
    }
    
    func allTrackersFilter() {
        filterTrackersBySelectedDate(datePicker)
        collectionView.reloadData()
    }
    
    func trackersForTodayFilter() {
        datePicker.date = Date()
        todaysTrackers()
    }
    
    func completedTrackersFilter() {
        filterTrackersBySelectedDate(datePicker)
        
        var completed : [TrackerCategory] = []
        for categoryIndex in 0..<visibleCategories.count {
            var trackers : [Tracker] = []
            for trackerIndex in 0..<visibleCategories[categoryIndex].trackers.count {
                if isCompleted(visibleCategories[categoryIndex].trackers[trackerIndex]) {
                    if let index = completed.firstIndex(where: {$0.category == visibleCategories[categoryIndex].category}) {
                        trackers.append(visibleCategories[categoryIndex].trackers[trackerIndex])
                        for tracker in completed[index].trackers {
                            trackers.append(tracker)
                        }
                        let newCategory = TrackerCategory(category: completed[index].category, trackers: trackers)
                        completed[index] = newCategory
                    } else {
                        let newCategory = TrackerCategory(
                            category: visibleCategories[categoryIndex].category,
                            trackers: [visibleCategories[categoryIndex].trackers[trackerIndex]]
                        )
                        completed.append(newCategory)
                    }
                }
            }
        }
        visibleCategories = completed
        collectionView.reloadData()
    }
    
    func incompleteTrackersFilter() {
        filterTrackersBySelectedDate(datePicker)
        
        var incomplete : [TrackerCategory] = []
        for categoryIndex in 0..<visibleCategories.count {
            var trackers : [Tracker] = []
            for trackerIndex in 0..<visibleCategories[categoryIndex].trackers.count {
                if !isCompleted(visibleCategories[categoryIndex].trackers[trackerIndex]) {
                    if let index = incomplete.firstIndex(where: {$0.category == visibleCategories[categoryIndex].category}) {
                        trackers.append(visibleCategories[categoryIndex].trackers[trackerIndex])
                        for tracker in incomplete[index].trackers {
                            trackers.append(tracker)
                        }
                        let newCategory = TrackerCategory(category: incomplete[index].category, trackers: trackers)
                        incomplete[index] = newCategory
                    } else {
                        let newCategory = TrackerCategory(
                            category: visibleCategories[categoryIndex].category,
                            trackers: [visibleCategories[categoryIndex].trackers[trackerIndex]]
                        )
                        incomplete.append(newCategory)
                    }
                }
            }
        }
        visibleCategories = incomplete
        collectionView.reloadData()
    }
    
    
}

extension TrackerViewController: HabbitCreatorProtocol {
    func didUpdateTracker() {
        reloadData()
    }
    
    func didCreateTracker() {
        reloadData()
    }
}

extension TrackerViewController: DataProviderDelegate {
    func didUpdate() {
        reloadData()
    }
}


