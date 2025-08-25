import UIKit

protocol HabbitCreatorProtocol: AnyObject {
    func didCreateTracker()
    func didUpdateTracker()
}

final class HabbitCreatorViewController: UIViewController {
    
    init(dataProvider: DataProviderProtocol, trackerToEdit: Tracker? = nil) {
        self.dataProvider = dataProvider
        self.categoryViewModel = CategoryViewModel(dataProvider: dataProvider)
        self.trackerToEdit = trackerToEdit
        self.isEditingMode = trackerToEdit != nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("new_habit", comment: "")
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("character_limit", comment: "")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .systemRed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.placeholder = NSLocalizedString("tracker_name_placeholder", comment: "")
        textField.backgroundColor = .secondarySystemBackground
        textField.textColor = .label
        textField.setLeftPaddingPoints(12)
        textField.setRightPaddingPoints(12)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBackground
        button.tintColor = .label
        button.setTitleColor(.systemBackground, for: .normal)
        return button
    }()
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.backgroundColor = .systemBackground
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        collectionView.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: EmojiCollectionCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var emojiCollectionHeaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.text = NSLocalizedString("emoji", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        collectionView.register(ColorCollectionCell.self, forCellWithReuseIdentifier: ColorCollectionCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var colorCollectionHeaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.text = NSLocalizedString("color", comment: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let categoryViewModel: CategoryViewModelProtocol
    private lazy var scheduleVC = ScheduleViewController()
    private lazy var categoryVC = CategoryViewController(viewModel: categoryViewModel)
    
    private let options = [
        NSLocalizedString("category", comment: ""),
        NSLocalizedString("schedule", comment: "")
    ]
    private var selectedCategory: String = ""
    private var selectedSchedule: Set<Weekday> = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private let habbitButtonColor = UIColor(resource: .darkAppearenceButton)
    //edit properties
    private var isEditingMode: Bool = false
    private var trackerToEdit: Tracker?
    private var originalCategory: String = ""
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    weak var delegate: HabbitCreatorProtocol?
    private let dataProvider: DataProviderProtocol
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupEmojiCollectionView()
        setupColorCollectionView()
        textField.delegate = self
        updateCreateButtonState()
        categoryViewModel.delegate = self
        view.backgroundColor = .systemBackground
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        view.addSubview(titleLabel)
        view.addSubview(createButton)
        view.addSubview(cancelButton)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(warningLabel)
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -8),
        ])
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 40),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            warningLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
        ])
        
        NSLayoutConstraint.activate([
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: 161),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 161),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    private func setupTableView(){
        tableView.register(OptionTableViewCell.self, forCellReuseIdentifier: OptionTableViewCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .secondarySystemBackground
        tableView.layoutMargins = .zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.separatorInset = .zero
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.contentInset = UIEdgeInsets.init(top: -35, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 1, right: 16)
        contentView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 32),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupEmojiCollectionView(){
        contentView.addSubview(emojiCollectionHeaderLabel)
        contentView.addSubview(emojiCollectionView)
        NSLayoutConstraint.activate([
            emojiCollectionHeaderLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiCollectionHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiCollectionView.topAnchor.constraint(equalTo: emojiCollectionHeaderLabel.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 180)
            
        ])
    }
    
    private func setupColorCollectionView(){
        contentView.addSubview(colorCollectionHeaderLabel)
        contentView.addSubview(colorCollectionView)
        NSLayoutConstraint.activate([
            colorCollectionHeaderLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 32),
            colorCollectionHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorCollectionView.topAnchor.constraint(equalTo: colorCollectionHeaderLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    
    func configureForEditing(tracker: Tracker, category: String) {
        self.trackerToEdit = tracker
        self.originalCategory = category
        self.isEditingMode = true
        
        titleLabel.text = NSLocalizedString("edit_tracker", comment: "Edit tracker title")
        createButton.setTitle(NSLocalizedString("save", comment: "Save button title"), for: .normal)
        
        textField.text = tracker.name
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        selectedSchedule = Set(tracker.schedule)
        selectedCategory = category
        
        emojiCollectionView.reloadData()
        colorCollectionView.reloadData()
        
        updateEmojiSelection()
        updateColorSelection()
        
        tableView.reloadData()
        
        updateCreateButtonState()
    }
    
    @objc private func createButtonTapped() {
        
        AnalyticsService.trackEvent(AnalyticsEvent(
            event: .click,
            screen: .newHabitOrEvent,
            item: .create)
        )
        
        guard let trackerName = textField.text, !trackerName.isEmpty else {
            warningLabel.isHidden = false
            return
        }
        
        if isEditingMode {
            // Update existing tracker
            updateExistingTracker(name: trackerName)
        } else {
            // Create new tracker
            createNewTracker(name: trackerName)
        }
    }
    
    private func createNewTracker(name: String) {
        guard let selectedEmoji else { return }
        guard let selectedColor else { return }
        if !name.isEmpty && !selectedCategory.isEmpty && !selectedSchedule.isEmpty{
            let tracker = Tracker(
                id: UUID(),
                name: name,
                emoji: selectedEmoji,
                color: selectedColor,
                schedule: Array(self.selectedSchedule)
            )
            
            dataProvider.addTrackertoCategory(tracker, selectedCategory)
            delegate?.didCreateTracker()
            dismiss(animated: true)
        }
    }
    
    private func updateExistingTracker(name: String) {
        guard let tracker = trackerToEdit else { return }
        guard let selectedEmoji else { return }
        guard let selectedColor else { return }
        if !name.isEmpty && !selectedCategory.isEmpty && !selectedSchedule.isEmpty {
            let updatedTracker = Tracker(
                id: tracker.id, // Keep the same ID
                name: name,
                emoji: selectedEmoji,
                color: selectedColor,
                schedule: Array(self.selectedSchedule)
            )
            
            // Update the tracker
            dataProvider.updateTracker(updatedTracker)
            
            // If category changed, we need to handle that
            if selectedCategory != originalCategory {
                // Remove from old category and add to new category
                dataProvider.deleteTracker(tracker)
                dataProvider.addTrackertoCategory(updatedTracker, selectedCategory)
            }
            
            delegate?.didUpdateTracker()
            dismiss(animated: true)
        }
    }
    private func updateEmojiSelection() {
        guard let selectedEmoji = selectedEmoji else { return }
        
        if let index = AppResources.trackerEmojis.firstIndex(of: selectedEmoji) {
            let indexPath = IndexPath(item: index, section: 0)
            
            if let cell = emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionCell {
                cell.setSelected(true)
            }
            
            emojiCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }
    }
    
    private func updateColorSelection() {
        guard let selectedColor = selectedColor else { return }
        
        if let index = AppResources.trackerColors.firstIndex(of: selectedColor) {
            let indexPath = IndexPath(item: index, section: 0)
            
            if let cell = colorCollectionView.cellForItem(at: indexPath) as? ColorCollectionCell {
                cell.setSelected(true, color: selectedColor)
            }
            
            colorCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }
    }

    @objc private func cancelButtonTapped(){
        
        AnalyticsService.trackEvent(AnalyticsEvent(
            event: .click,
            screen: .newHabitOrEvent,
            item: .cancel)
        )
        
        self.dismiss(animated: true)
    }
    
    private func updateCreateButtonState() {
        let isNameValid = !(textField.text ?? "").isEmpty && (textField.text ?? "").count <= 38
        let isCategorySelected = !selectedCategory.isEmpty
        let isScheduleSelected = !selectedSchedule.isEmpty
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        
        let shouldBeEnabled = isNameValid && isCategorySelected && isScheduleSelected && isEmojiSelected && isColorSelected
        //animation test
        if createButton.isEnabled != shouldBeEnabled {
            UIView.transition(with: createButton, duration: 0.3, options: .transitionCrossDissolve) {
                self.createButton.isEnabled = shouldBeEnabled
                self.createButton.backgroundColor = shouldBeEnabled ? self.habbitButtonColor : UIColor(resource: .ypGrey)
            }
        } else {
            createButton.isEnabled = shouldBeEnabled
            createButton.backgroundColor = shouldBeEnabled ? habbitButtonColor : UIColor(resource: .ypGrey)
        }
    }
}

extension HabbitCreatorViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        warningLabel.isHidden = updatedText.count < 38
        updateCreateButtonState()
        return updatedText.count <= 38
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
    }
}

extension HabbitCreatorViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OptionTableViewCell.reuseIdentifier, for: indexPath) as! OptionTableViewCell
        let option = options[indexPath.row]
        cell.textLabel?.text = option
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .secondarySystemBackground
        cell.layer.cornerRadius = 16
        cell.detailTextLabel?.text = nil
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = selectedCategory
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else {
            if selectedSchedule.isEmpty {
                cell.detailTextLabel?.text = nil
            } else {
                let sortedWeekdays = selectedSchedule.sorted { $0.rawValue < $1.rawValue }
                let scheduleString = sortedWeekdays.map { $0.shortDescription }.joined(separator: ", ")
                cell.detailTextLabel?.text = scheduleString
            }
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        cell.layer.masksToBounds = true
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            updateCreateButtonState()
            
            let categoryNC = UINavigationController(rootViewController: categoryVC)
            present(categoryNC, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            scheduleVC.delegate = self
            
            
            if isEditingMode {
                scheduleVC.setInitialSelection(selectedSchedule)
            }
            present(scheduleVC, animated: true, completion: nil)
        }
    }
}

extension HabbitCreatorViewController: ScheduleViewControllerDelegate {
    func didSelectSchedule(_ schedule: Set<Weekday>) {
        self.selectedSchedule = schedule
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        updateCreateButtonState()
    }
}

extension HabbitCreatorViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var emojiItemSize: CGFloat { 50 }
    private var emojiItemsPerRow: CGFloat { 6 }
    private var emojiSectionInsets: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private var colorItemSize: CGFloat { 50 }
    private var colorItemsPerRow: CGFloat { 6 }
    private var colorSectionInsets: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView{
            return AppResources.trackerEmojis.count
        } else {
            return AppResources.trackerColors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView{
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionCell.reuseIdentifier, for: indexPath) as? EmojiCollectionCell else {
                fatalError("Failed to dequeue EmojiCollectionCell")
            }
            let emoji = AppResources.trackerEmojis[indexPath.item]
            cell.configure(with: emoji)
            cell.layer.masksToBounds = true
            
            if let currentSelectedEmoji = selectedEmoji, currentSelectedEmoji == emoji {
                cell.setSelected(true)
            } else {
                cell.setSelected(false)
            }
            
            updateCreateButtonState()
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionCell.reuseIdentifier, for: indexPath) as? ColorCollectionCell else {
                fatalError( "Failed to dequeue ColorCollectionCell")
            }
            let color = AppResources.trackerColors[indexPath.item]
            cell.configure(with: color)
            cell.layer.masksToBounds = true
            
            if let currentSelectedColor = selectedColor, currentSelectedColor == color {
                cell.setSelected(true, color: color)
            } else {
                cell.setSelected(false, color: color)
            }
            
            updateCreateButtonState()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView{
            if let previousSelectedEmoji = collectionView.indexPathsForSelectedItems?.first, previousSelectedEmoji != indexPath {
                collectionView.deselectItem(at: previousSelectedEmoji, animated: true)
                if let previousCell = collectionView.cellForItem(at: previousSelectedEmoji) as? EmojiCollectionCell {
                    previousCell.backgroundColor = .clear
                    previousCell.layer.cornerRadius = 0
                }
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionCell{
                cell.backgroundColor = UIColor(resource: .emojiSelection)
                cell.layer.cornerRadius = 16
            }
            selectedEmoji = AppResources.trackerEmojis[indexPath.item]
            print("selected \(selectedEmoji ?? "none")")
            updateCreateButtonState()
        } else {
            if let previousSelectedColor = collectionView.indexPathsForSelectedItems?.first, previousSelectedColor != indexPath {
                collectionView.deselectItem(at: previousSelectedColor, animated: true)
                if let previousCell = collectionView.cellForItem(at: previousSelectedColor) as? ColorCollectionCell {
                    previousCell.backgroundColor = .clear
                    previousCell.layer.cornerRadius = 0
                }
            }
            selectedColor = AppResources.trackerColors[indexPath.item]
            print("selected \(selectedColor)")
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionCell{
                cell.layer.borderWidth = 3
                cell.layer.masksToBounds = true
                cell.layer.cornerRadius = 16
                cell.layer.borderColor = AppResources.trackerColors[indexPath.item].withAlphaComponent(0.3).cgColor
                updateCreateButtonState()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView{
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionCell{
                cell.backgroundColor = .clear
                cell.layer.cornerRadius = 0
            }
        } else {
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionCell{
                cell.layer.borderWidth = 0
                cell.layer.borderColor = .none
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == emojiCollectionView{
            return CGSize(width: emojiItemSize, height: emojiItemSize)
        } else {
            return CGSize(width: colorItemSize, height: colorItemSize)
        }
    }
}

extension HabbitCreatorViewController: CategoryViewModelDelegate {
    func category(_ category: String) {
        selectedCategory = category
        tableView.reloadData()
    }
    
}
