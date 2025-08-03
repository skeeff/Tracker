import UIKit

final class TrackerViewController: UIViewController{
    //MARK: Properties
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var completedRecords: Set<TrackerRecord> = []
    private let dateFormatter = DateFormatter()
    private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    
    
    private var trackerStore: TrackerStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(CategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
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
        temporaryLabel.text = "Что будем отслеживать?"
        temporaryLabel.font = .systemFont(ofSize: 12, weight: .medium)
        temporaryLabel.textColor = .black
        temporaryLabel.translatesAutoresizingMaskIntoConstraints = false
        return temporaryLabel
    }()
    
    private lazy var trackersLabel: UILabel = {
        let temporaryLabel = UILabel()
        temporaryLabel.text = "Трекеры"
        temporaryLabel.font = .systemFont(ofSize: 34, weight: .bold)
        temporaryLabel.textColor = .black
        temporaryLabel.translatesAutoresizingMaskIntoConstraints = false
        return temporaryLabel
    }()
    
    private lazy var searchField: UISearchTextField = {
        let temporarySearchField = UISearchTextField()
        temporarySearchField.placeholder = "Поиск"
        temporarySearchField.layer.cornerRadius = 8
        temporarySearchField.clipsToBounds = true
        temporarySearchField.translatesAutoresizingMaskIntoConstraints = false
        return temporarySearchField
    }()
    
    init(trackerStore: TrackerStoreProtocol,
         trackerRecordStore: TrackerRecordStoreProtocol,
         trackerCategoryStore: TrackerCategoryStoreProtocol) {
        
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
        self.trackerCategoryStore = trackerCategoryStore
        
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
        //        filterTrackersBySelectedDate()
        
        trackerStore.delegate = self
        
        do {
            try trackerStore.fetchTrackers(forSelectedDate: selectedDate, withSearchText: nil)
        } catch {
            print("Failed to fetch initial trackers: \(error)")
        }
        updatePlaceholderVisibility()
                //mockInitialData() // ==> Для тестов
    }
    
    private func setupUI(){
        
        view.addSubview(trackersLabel)
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            trackersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 105)
        ])
        
        view.addSubview(searchField)
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 36),
        ])
        
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
        let hasVisibleTrackers = (trackerStore.numberOfSections > 0)
        
        if !hasVisibleTrackers {
            placeholderImageView.image = UIImage(named: "trackers_placeholder")
            placeholderLabel.text = "Что будем отслеживать?"
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    private func filterTrackersBySelectedDate(){
        let selectedWeekday = Weekday.from(date: selectedDate)
        filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(selectedWeekday)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(category: category.category, trackers: filteredTrackers)
        }
        collectionView.reloadData()
        updatePlaceholderVisibility()
        
    }
    
//    private func initialCategorySetup(){
//        do {
//               // Проверяем, есть ли категории.
//               let hasCategories = try trackerCategoryStore.countCategories() > 0
//               if !hasCategories {
//                   // Если категорий нет, создаем одну по умолчанию.
//                   try trackerCategoryStore.createCategory(name: "Основная категория")
//               }
//           } catch {
//               print("Failed to initialize default category: \(error)")
//           }
//    }
    
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
        do {
            try trackerStore.fetchTrackers(forSelectedDate: selectedDate, withSearchText: searchField.text)
            collectionView.reloadData()
            updatePlaceholderVisibility()
        } catch {
            print("Failed to fetch trackers on date change: \(error)")
        }
    }
    
    private func mockInitialData() {
        let color1 = UIColor.red
        let color2 = UIColor.blue
        let color3 = UIColor.green
        
        let tracker1 = Tracker(name: "Изучать Swift", emoji: "👩‍💻", color: color1, schedule: [.monday, .wednesday, .friday])
        let tracker2 = Tracker(name: "Заниматься спортом", emoji: "💪", color: color2, schedule: [.tuesday, .thursday])
        let tracker3 = Tracker(name: "Читать книги", emoji: "📚", color: color3, schedule: Set(Weekday.allCases))
        let tracker4 = Tracker(name: "Гулять с собакой", emoji: "🐶", color: color1, schedule: [.saturday, .sunday])
        let tracker5 = Tracker(name: "Медитировать", emoji: "🧘‍♀️", color: color2, schedule: [.monday, .tuesday, .wednesday, .thursday, .friday])
        
        let category1 = TrackerCategory(category: "Привычки", trackers: [tracker1, tracker2, tracker3])
        let category2 = TrackerCategory(category: "Домашние дела", trackers: [tracker4])
        let category3 = TrackerCategory(category: "Саморазвитие", trackers: [tracker5])
        
        categories = [category1, category2, category3]
        
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        completedRecords.insert(TrackerRecord(id: tracker1.id, date: yesterday))
        completedRecords.insert(TrackerRecord(id: tracker2.id, date: yesterday))
        completedRecords.insert(TrackerRecord(id: tracker1.id, date: today))
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            fatalError("Failed to dequeue TrackerCell")
        }
        guard let tracker = trackerStore.getTracker(at: indexPath) else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        let normalizedDate = Calendar.current.startOfDay(for: selectedDate)
        let isCompletedForSelectedDate = completedRecords.contains(TrackerRecord(id: tracker.id, date: normalizedDate))
        let daysCompleted = completedRecords.filter { $0.id == tracker.id }.count
        let isInteractionAllowed = normalizedDate <= Calendar.current.startOfDay(for: Date())
        
        
        
        //        guard indexPath.section < filteredCategories.count,
        //              indexPath.item < filteredCategories[indexPath.section].trackers.count else {
        //            return UICollectionViewCell()
        //        }
        //        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        //        cell.delegate = self
        //        let normalizedDate = Calendar.current.startOfDay(for: selectedDate)
        //        let isCompletedForSelectedDate = completedRecords.contains(TrackerRecord(id: tracker.id, date: normalizedDate))
        //        let daysCompleted = completedRecords.filter { $0.id == tracker.id }.count
        //        let isInteractionAllowed = normalizedDate <= Calendar.current.startOfDay(for: Date())
        cell.configure(
            with: tracker,
            isCompletedForSelectedDate: isCompletedForSelectedDate,
            daysCompleted: daysCompleted,
            isInteractionAllowed: isInteractionAllowed
        )
        return cell
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfRowsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? CategoryHeaderView else {
            fatalError("Failed to dequeue CategoryHeaderView")
        }
        header.headerLabel.text = trackerStore.getTrackerCategoryTitle(for: indexPath.section)
        return header
    }
}

extension TrackerViewController: TrackerCellDelegate {
    func didTapAddButton(for trackerID: UUID) {
        
        let normalizedDate = Calendar.current.startOfDay(for: selectedDate)
        guard normalizedDate <= Calendar.current.startOfDay(for: Date()) else {
            let alert = UIAlertController(title: "Ошибка", message: "Нельзя отметить трекер для будущей даты", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        do {
            try trackerRecordStore.addRecord(forTrackerID: trackerID, date: normalizedDate)
            collectionView.reloadData()
            updatePlaceholderVisibility()
        } catch {
            print("Failed to add record: \(error)")
        }
    }
    func didTapRemoveButton(for trackerID: UUID){
        let normalizedDate = Calendar.current.startOfDay(for: selectedDate)
        guard normalizedDate <= Calendar.current.startOfDay(for: Date()) else{
            print("Невозможно снять отметку с будущeй даты")
            return
        }
        do {
            try trackerRecordStore.removeRecord(forTrackerID: trackerID, date: normalizedDate)
            collectionView.reloadData()
            updatePlaceholderVisibility()
        } catch {
            print("Failed to remove record: \(error)")
        }
        //        let recordToRemove = TrackerRecord(id: trackerID, date: normalizedDate)
        //        completedRecords.remove(recordToRemove)
        //        collectionView.reloadData()
        //        updatePlaceholderVisibility()
        
    }
}

extension TrackerViewController: HabbitCreatorProtocol {
    func didCreateTracker(_ tracker: Tracker, in categoryName: String) {
        let targetCategoryName = categoryName.isEmpty ? "Мои трекеры" : categoryName
        
        do {
            try trackerStore.createTracker(name: tracker.name, emoji: tracker.emoji, color: tracker.color.uiColor, schedule: tracker.schedule, categoryName: targetCategoryName)
            
            try trackerStore.fetchTrackers(forSelectedDate: selectedDate, withSearchText: searchField.text)
            dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.collectionView.reloadData()
                self.updatePlaceholderVisibility()
            }
        } catch {
            print("Failed to create tracker: \(error)")
        }
        
        //        if let index = categories.firstIndex(where: { $0.category == targetCategoryName }) {
        //            let existingCategory = categories[index]
        //            let updatedTrackers = existingCategory.trackers + [tracker]
        //            let updatedCategory = TrackerCategory(id: existingCategory.id, category: existingCategory.category, trackers: updatedTrackers)
        //            categories[index] = updatedCategory
        //        } else {
        //            let newCategory = TrackerCategory(category: targetCategoryName, trackers: [tracker])
        //            categories.append(newCategory)
        //        }
        //        dismiss(animated: true) { [weak self] in
        //            guard let self = self else { return }
        //            self.filterTrackersBySelectedDate()
        //            self.collectionView.reloadData()
    }
    
}




extension TrackerViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
}



