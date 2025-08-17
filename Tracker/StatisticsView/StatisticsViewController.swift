
import UIKit

final class StatisticsViewController: UIViewController {
    
    //MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticsCell.self,
                           forCellReuseIdentifier: reuseIdentfier)
        return tableView
    }()
    
    private let placeholder = Placeholder.shared
    private let reuseIdentfier: String = StatisticsCell.reuseIdentifier
    
    /// Названия метрик
    private let statistics = [
        NSLocalizedString("complete_trackers", comment: "")
    ]
    
    /// Выполненные записи трекеров
    private var records: Set<TrackerRecord> = []
    
    /// Провайдер данных
    private var dataProvider: DataProviderProtocol?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDataProvider()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsService.trackEvent(AnalyticsEvent(
              event: .open,
              screen: .statistics,
              item: .openedStatistics))

        records = dataProvider?.getCompletedRecords() ?? []
        tableView.reloadData()
    }
    
    //MARK: - Setup
    
    private func setupDataProvider() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let trackerStore = TrackerStore(
            context: context,
            appDelegate: appDelegate
        )
        let trackerCategoryStore = TrackerCategoryStore(
            trackerStore: trackerStore
        )
        let trackerRecordStore = TrackerRecordStore(context: context)
        
        /// Сохраняем в свойство, а не в локальную переменную!
        self.dataProvider = DataProvider(
            categoryStore: trackerCategoryStore,
            trackerStore: trackerStore,
            recordStore: trackerRecordStore
        )
    }
    
    private func setupUI() {
        navigationItem.title = NSLocalizedString("statistics", comment: "")
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

//MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard records.count > 0 else {
            placeholder.showPlaceholder(
                image: UIImage(resource: .statisticsPlaceholder),
                text: NSLocalizedString("nothing_to_analyze", comment: ""),
                view: view
            )
            return 0
        }
        
        placeholder.removePlaceholder()
        return statistics.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: reuseIdentfier,
                for: indexPath
            ) as? StatisticsCell
        else {
            return UITableViewCell()
        }
        
        cell.configureCell(
            counter: records.count,                     // 👈 количество завершённых трекеров
            title: statistics[indexPath.row]            // 👈 локализованный заголовок
        )
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
}

//
//import UIKit
//
//
//final class StatisticsViewController: UIViewController {
//    
//    //MARK: - Properties
//    
//    private lazy var tableView: UITableView = {
//        let tableView = UITableView(frame: .zero,
//                                    style: .plain)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.layer.cornerRadius = 16
//        tableView.separatorStyle = .none
//        tableView.allowsSelection = false
//        tableView.isScrollEnabled = false
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.register(StatisticsCell.self,
//                           forCellReuseIdentifier: reuseIdentfier)
//        return tableView
//    }()
//    
//    private let placeholder = Placeholder.shared
//    
//    private let reuseIdentfier: String = StatisticsCell.reuseIdentifier
//    
//    private let statistics = [NSLocalizedString("completedtrackers", comment: "")]
//    
//    private var records: Set<TrackerRecord> = []
//    
//    private var dataProvider: DataProviderProtocol?
//    
//    //MARK: - Lifecycle methods
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//        
//        let trackerStore = TrackerStore(
//            context: context,
//            appDelegate: appDelegate
//        )
//        let trackerCategoryStore = TrackerCategoryStore(
//            trackerStore: trackerStore
//        )
//        
//        let trackerRecordStore = TrackerRecordStore(context: context)
//        
//        let dataProvider = DataProvider(categoryStore: trackerCategoryStore, trackerStore: trackerStore, recordStore: trackerRecordStore)
//                
//        setupUI()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        records = dataProvider?.getCompletedRecords() ?? []
//        tableView.reloadData()
//    }
//    
//    //MARK: - Methods
//    
//    private func setupUI() {
//        navigationItem.title = NSLocalizedString("statistics", comment: "")
//        navigationItem.largeTitleDisplayMode = .always
//        
//        view.addSubview(tableView)
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 206),
//            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
//        ])
//    }
//}
//
////MARK: - UITableViewDataSource
//extension StatisticsViewController: UITableViewDataSource {
//    func tableView(
//        _ tableView: UITableView,
//        numberOfRowsInSection section: Int
//    ) -> Int {
//        guard
//            records.count > 0
//        else {
//            placeholder.showPlaceholder(
//                image: (UIImage(resource: .statisticsPlaceholder)),
//                text: NSLocalizedString("nothing_to_analyze", comment: ""),
//                view: view)
//            return 0
//        }
//        
//        placeholder.removePlaceholder()
//        return statistics.count
//    }
//    
//    func tableView(
//        _ tableView: UITableView,
//        cellForRowAt indexPath: IndexPath
//    ) -> UITableViewCell {
//        guard
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: reuseIdentfier,
//                for: indexPath
//            ) as? StatisticsCell
//        else {
//            return UITableViewCell()
//        }
//        
//        cell.configureCell(
//            counter: records.count,
//            title: statistics[indexPath.row]
//        )
//        
//        return cell
//    }
//}
//
////MARK: - UITableViewDelegate
//extension StatisticsViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        90
//    }
//}
