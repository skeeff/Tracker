import UIKit

final class CategoryViewController: UIViewController {
    
    init(viewModel: CategoryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let viewModel: CategoryViewModelProtocol
    
    private let placeholder = Placeholder.shared
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.layer.cornerRadius = 16 
        tableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        tableView.clipsToBounds = true
        tableView.separatorColor = .gray
        tableView.allowsMultipleSelection = false
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 1, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        return tableView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addPaddingToTextField()
        textField.textColor = .label
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .systemGray6
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.delegate = self
        return textField
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.systemBackground, for: .normal)
        button.addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private var newCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    private func bindViewModel() {
        // Подписываемся на обновление списка категорий
        viewModel.onCategoriesUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        // Подписываемся на изменение состояния
        viewModel.onStateChange = { [weak self] in
            self?.switchUI()
        }
    }
    
    private func setupUI() {
        view.addSubviews(tableView, textField, button)
        
        view.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 24),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -115),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                               constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -16),
            
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                               constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                           constant: -16),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                            constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                             constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        switchUI()
    }
    
    private func switchUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch viewModel.state {
            case .onboarding:
                title = "Категория"
                textField.isHidden = true
                tableView.isHidden = false
                button.setTitle(NSLocalizedString("Добавить категорию", comment: ""), for: .normal)
            case .choose:
                title = "Категория"
                textField.isHidden = true
                tableView.isHidden = false
                button.setTitle(NSLocalizedString("Добавить категорию", comment: ""), for: .normal)
                placeholder.removePlaceholder()
            case .create:
                title = "Новая категорию"
                tableView.isHidden = true
                textField.isHidden = false
                button.setTitle(NSLocalizedString("Готово", comment: ""), for: .normal)
                button.backgroundColor = .black.withAlphaComponent(0.3)
                button.isUserInteractionEnabled = false
                placeholder.removePlaceholder()
            }
        }
    }
    
    @objc private func didTapButton() {
        switch viewModel.state {
        case .onboarding, .choose:
            viewModel.didTapAddCategoryButton()
        case .create:
            viewModel.didTapDoneButton(with: textField.text ?? "")
        }
    }
    
    deinit {
        print("\(#function) categoryVC")
    }
}

extension CategoryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel.didBeginEditing()
        
        textField.text = ""
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard
            let text = textField.text,
            !text.isEmpty
        else { return }
        
        newCategory = text
        button.backgroundColor = .black
        button.isUserInteractionEnabled = true
        print(newCategory)
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.setSelectedCategory(at: indexPath)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.categories().count
        if count == 0 {
            return 0
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let category = viewModel.categories()[indexPath.row]
        let isSelected = viewModel.isSelected(at: indexPath)
        let isLast = indexPath.row == viewModel.categories().count - 1
        
        cell.textLabel?.text = category.category
        cell.selectionStyle = .none
        cell.backgroundColor = .systemGray6
        
        if isSelected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        if isLast {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            cell.layer.cornerRadius = 0 // Убираем скругление
        }
        
        cell.clipsToBounds = true
        
        return cell
        
    }
}


