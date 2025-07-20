import UIKit

protocol HabbitCreatorProtocol: AnyObject {
    func didCreateTracker(_ tracker: Tracker, in category: String)
}

final class HabbitCreatorViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
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
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .systemGray6
        textField.textColor = .black
        textField.setLeftPaddingPoints(12)
        textField.setRightPaddingPoints(12)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.backgroundColor = .white
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        collectionView.dataSource = self
//        collectionView.delegate = self
        return collectionView
    }()
    
    private let options = ["Категория", "Расписание"]
    private var selectedCategory: String?
    private var selectedSchedule: Set<Weekday> = []
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    weak var delegate: HabbitCreatorProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        tableView.register(OptionTableViewCell.self, forCellReuseIdentifier: OptionTableViewCell.reuseIdentifier)
        textField.delegate = self
        updateCreateButtonState()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(warningLabel)
        view.addSubview(textField)
        view.addSubview(createButton)
        view.addSubview(cancelButton)
        view.backgroundColor = .white
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.layoutMargins = .zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.separatorInset = .zero
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.contentInset = UIEdgeInsets.init(top: -35, left: 0, bottom: 0, right: 0)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 24),
//            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            tableView.widthAnchor.constraint(equalToConstant: 343),
        ])
    }
    
    @objc private func createButtonTapped(){
        let trackerName = textField.text ?? ""
        guard let randomEmoji = AppResources.trackerEmojis.randomElement() else { return }
                    guard let randomColor = AppResources.trackerColors.randomElement() else { return }
        
        if !trackerName.isEmpty && selectedCategory != nil && !selectedSchedule.isEmpty {
            let newTracker = Tracker(id: UUID(),
                                     name: trackerName,
                                     emoji: randomEmoji,
                                     color: randomColor,
                                     schedule: selectedSchedule)
            delegate?.didCreateTracker(newTracker, in: selectedCategory!)
            self.dismiss(animated: true)
        } else {
            print("ZAPOLNENO NE VSE")
        }
    }
    
    @objc private func cancelButtonTapped(){
        self.dismiss(animated: true)
    }
    
    private func updateCreateButtonState() {
        let isNameValid = !(textField.text ?? "").isEmpty && (textField.text ?? "").count <= 38
        let isCategorySelected = selectedCategory != nil
        let isScheduleSelected = !selectedSchedule.isEmpty
        
        createButton.isEnabled = isNameValid && isCategorySelected && isScheduleSelected
        createButton.backgroundColor = createButton.isEnabled ? .black : .systemGray3
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
        cell.backgroundColor = .systemGray6
        cell.layer.cornerRadius = 16
        cell.detailTextLabel?.text = nil
        if indexPath.row == 0 { // Категория
            cell.detailTextLabel?.text = selectedCategory
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            if let category = selectedCategory {
                            cell.detailTextLabel?.text = category
                        }
        } else { // Расписание
            // Форматируем выбранные дни недели для отображения
            if selectedSchedule.isEmpty {
                cell.detailTextLabel?.text = nil
            } else {
                let sortedWeekdays = selectedSchedule.sorted { $0.rawValue < $1.rawValue }
                let scheduleString = sortedWeekdays.map { $0.shortDescription }.joined(separator: ", ")
                cell.detailTextLabel?.text = scheduleString
            }
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude) // Убираем разделитель для последней
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
            print("Переход к выбору категории")
            // Предполагаем, что у вас есть CategorySelectionViewController
            // let categorySelectionVC = CategorySelectionViewController()
            // categorySelectionVC.delegate = self // Если CategorySelectionVC тоже использует делегат
            // present(categorySelectionVC, animated: true)
            // Временно для теста:
            self.selectedCategory = "Мои трекеры"
            tableView.reloadRows(at: [indexPath], with: .automatic)
            updateCreateButtonState()
        } else if indexPath.row == 1 { // Расписание
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            present(scheduleViewController, animated: true, completion: nil)
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

//extension HabbitCreatorViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return AppResources.trackerEmojis.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//    }
//    
//    func createLayout() -> UICollectionViewFlowLayout {
//        
//    }
//    
//}

