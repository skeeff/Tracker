import UIKit

final class TrackerViewController: UIViewController{
    //MARK: Properties
    //var categories: [TrackerCategory] = []
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private let dateFormatter = DateFormatter()
    private var selectedDate: Date = Date()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return collectionView
    }()
    
    //MARK: UI
    private lazy var placeholderImageView: UIImageView? = {
        let temporaryImage = UIImage(named: "trackers_placeholder")
        let temporaryImageView = UIImageView(image: temporaryImage)
        temporaryImageView.translatesAutoresizingMaskIntoConstraints = false
        return temporaryImageView
    }()
    
    private lazy var placeholderLabel: UILabel? = {
        let temporaryLabel = UILabel()
        temporaryLabel.text = "Что будем отслеживать?"
        temporaryLabel.font = .systemFont(ofSize: 12, weight: .medium)
        temporaryLabel.textColor = .black
        temporaryLabel.translatesAutoresizingMaskIntoConstraints = false
        return temporaryLabel
    }()
    
    private lazy var trackersLabel: UILabel? = {
        let temporaryLabel = UILabel()
        temporaryLabel.text = "Трекеры"
        temporaryLabel.font = .systemFont(ofSize: 34, weight: .bold)
        temporaryLabel.textColor = .black
        temporaryLabel.translatesAutoresizingMaskIntoConstraints = false
        return temporaryLabel
    }()
    
    private lazy var searchField: UISearchTextField? = {
        let temporarySearchField = UISearchTextField()
        temporarySearchField.placeholder = "Поиск"
        temporarySearchField.layer.cornerRadius = 8
        temporarySearchField.clipsToBounds = true
        temporarySearchField.translatesAutoresizingMaskIntoConstraints = false
        return temporarySearchField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupUI()
        filterTrackersBySelectedDate()
        updatePlaceholderVisibility()
    }
    
    private func setupUI(){
        
        guard let trackersLabel = trackersLabel else { return }
        view.addSubview(trackersLabel)
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            trackersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 105)
        ])
        
        guard let searchField = searchField else { return }
        view.addSubview(searchField)
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            searchField.widthAnchor.constraint(equalToConstant: 343)
        ])
        
        guard let placeholderImageView = placeholderImageView, let placeholderLabel = placeholderLabel else { return }
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
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupCategories(){
        if categories.isEmpty {
            categories.append(TrackerCategory(category: "Мои трекеры", trackers: []))
        }
        updatePlaceholderVisibility()
    }
    
    private func setupNavigationController(){
        guard self.navigationController != nil else { return }
        
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = addButton
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
        navigationItem.title = ""
        
    }
    
    private func updatePlaceholderVisibility(){
        let hasTrackers = categories.contains(where: { !$0.trackers.isEmpty })
        placeholderImageView?.isHidden = hasTrackers
        placeholderLabel?.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
    }
    
    private func filterTrackersBySelectedDate(){
        let selectedWeekday = Weekday.from(date: selectedDate)
        filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(selectedWeekday)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(category: category.category, trackers: filteredTrackers)
        }
        updatePlaceholderVisibility()
        
    }
    
    //MARK: objc
    @objc private func addButtonTapped(){
        let habbitCreatorVC = HabbitCreatorViewController()
        habbitCreatorVC.modalPresentationStyle = .pageSheet
        habbitCreatorVC.modalTransitionStyle = .coverVertical
        habbitCreatorVC.delegate = self
        present(habbitCreatorVC, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker){
        selectedDate = Calendar.current.startOfDay(for: sender.date)
        filterTrackersBySelectedDate()
        collectionView.reloadData()
        //        dismiss(animated: true)
    }
}
// MARK: Extensions
extension TrackerViewController:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(167), heightDimension: .absolute(148))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(148))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(16)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16)
            
            // заголовок
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .estimated(30))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .topLeading)
            
            section.boundarySupplementaryItems = [header]
            return section
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell ?? TrackerCell()
        guard indexPath.section < filteredCategories.count,
              indexPath.item < filteredCategories[indexPath.section].trackers.count else {
            return UICollectionViewCell()
        }
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        cell.delegate = self
        let isCompletedForSelectedDate = tracker.completedDates.contains(Calendar.current.startOfDay(for: selectedDate))
        var mutableTracker = tracker
        mutableTracker.isCompletedToday = isCompletedForSelectedDate
        cell.configure(with: mutableTracker, selectedDate: selectedDate)
        return cell
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < filteredCategories.count else { return 0 }
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CategoryHeaderView
        guard indexPath.section < filteredCategories.count else { return header }
        header.headerLabel.text = filteredCategories[indexPath.section].category
        return header
    }
}

extension TrackerViewController: TrackerCellDelegate {
    func didTapAddButton(on cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let currentFilteredTracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        if let categoryIndex = categories.firstIndex(where: {$0.category == filteredCategories[indexPath.section].category}),
        let trackerIndex = categories[categoryIndex].trackers.firstIndex(where: {$0.id == currentFilteredTracker.id}){
            var tracker = categories[categoryIndex].trackers[trackerIndex]
            let today = Calendar.current.startOfDay(for: selectedDate)
            if !tracker.completedDates.contains(today) {
                tracker.daysCompleted += 1
                tracker.completedDates.insert(today)
                tracker.isCompletedToday = true
            }
            categories[categoryIndex].trackers[trackerIndex] = tracker
            
            filterTrackersBySelectedDate()
            collectionView.reloadItems(at: [indexPath])
        }
        
    }
    func didTapRemoveButton(on cell: TrackerCell){
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let currentTrackerInFiltered = filteredCategories[indexPath.section].trackers[indexPath.item]
        
        if let categoryIndex = categories.firstIndex(where: { $0.category == filteredCategories[indexPath.section].category }),
           let trackerIndex = categories[categoryIndex].trackers.firstIndex(where: { $0.id == currentTrackerInFiltered.id }) {
            
            var tracker = categories[categoryIndex].trackers[trackerIndex]
            let today = Calendar.current.startOfDay(for: selectedDate)
            
            if tracker.completedDates.contains(today) {
                tracker.daysCompleted = max(0, tracker.daysCompleted - 1)
                tracker.completedDates.remove(today)
            }
            
            categories[categoryIndex].trackers[trackerIndex] = tracker
            
            filterTrackersBySelectedDate()
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

extension TrackerViewController: HabbitCreatorProtocol {
    func didCreateTracker(_ tracker: Tracker, in category: String) {
        if let index = categories.firstIndex(where: { $0.category == category }) {
            categories[index].trackers.append(tracker)
        } else {
            let newCategory = TrackerCategory(category: category, trackers: [tracker])
            categories.append(newCategory)
        }
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.filterTrackersBySelectedDate()
            self.collectionView.reloadData() 
        }
        
    }
    
    
}


