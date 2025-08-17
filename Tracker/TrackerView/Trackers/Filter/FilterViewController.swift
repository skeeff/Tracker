import UIKit


final class FilterViewController: UIViewController {
    
    //MARK: - Init
    
    init(
        viewModel: FilterViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(resource: .ypGrey)
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 1, right: 16)
        tableView.tableHeaderView = UIView()
        tableView.allowsMultipleSelection = false
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var viewModel: FilterViewModelProtocol
    
    private let filters: [Filter] = [
        .all,
        .today,
        .complete,
        .incomplete
    ]
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    //MARK: - Methods
    
    private func bind() {
        viewModel.onFiltersUpdate = { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func setupUI() {
        title = NSLocalizedString("filter_title", comment: "")
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: 24),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -115),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                               constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -16),
        ])
    }
}

//MARK: - UITableViewDataSource
extension FilterViewController: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor = .secondarySystemBackground
        cell.textLabel?.text = filters[indexPath.row].localized
        cell.selectionStyle = .default
        cell.layer.cornerRadius = 16
        
        if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == filters.count - 1 {
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            cell.layer.cornerRadius = 0
        }
        cell.layer.masksToBounds = true
        cell.preservesSuperviewLayoutMargins = false
        //                cell.separatorInset = .zero
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.layoutMargins = .zero
        
        
        cell.clipsToBounds = true
        
        
//        if indexPath.row == filters.count - 1 {
//            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
//            cell.layer.cornerRadius = 16
//            cell.layer.maskedCorners = [.layerMaxXMaxYCorner,
//                                        .layerMinXMaxYCorner]
//        }
        
        if viewModel.isSelected(filter: filters[indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension FilterViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        75
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        AnalyticsService.trackEvent(AnalyticsEvent(
             event: .open,
             screen: .main,
             item: .selectedFilter)
         )
        
        viewModel.setSelected(filter: filters[indexPath.row])
        self.dismiss(animated: true)
    }
}
