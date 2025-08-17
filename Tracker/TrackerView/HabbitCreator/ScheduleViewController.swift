import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectSchedule(_ schedule: Set<Weekday>)
}

final class ScheduleViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("schedule", comment: "")
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("done", comment: ""), for: .normal)
        button.backgroundColor = UIColor(resource: .darkAppearenceButton)
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let weekdays = Weekday.allCases
    private var selectedWeekdays: Set<Weekday> = []
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        view.backgroundColor = .systemBackground
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
    }
    
    private func setupUI(){
        view.addSubview(titleLabel)
        view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTableView(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
        tableView.layoutMargins = .zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.separatorInset = .zero
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
//            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
//            tableView.widthAnchor.constraint(equalToConstant: 343),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(weekdays.count) * 80)
        ])
    }
    
    func setInitialSelection(_ weekdays: Set<Weekday>) {
        selectedWeekdays = weekdays
        tableView.reloadData()
    }
    
    @objc func doneButtonTapped() {
        delegate?.didSelectSchedule(selectedWeekdays)
        self.dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.reuseIdentifier, for: indexPath) as? ScheduleCell else {
            fatalError("Unable to dequeue ScheduleCell")
        }
        let weekday = weekdays[indexPath.row]
        let isOn = selectedWeekdays.contains(weekday)
        cell.configure(with: weekday.description, isOn: isOn)
//        cell.configure(with: weekday.description, isOn: false)
        cell.backgroundColor = .secondarySystemBackground
        cell.layer.cornerRadius = 16
        if indexPath.row == 0 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == weekdays.count - 1 {
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            cell.layer.maskedCorners = []
            cell.separatorInset = .zero
        }
        cell.layer.masksToBounds = true
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
}

extension ScheduleViewController: ScheduleCellDelegate {
    func didToggleSwitch(for day: String, isOn: Bool) {
        if let weekday = Weekday.allCases.first(where: { $0.description == day }) {
            if isOn {
                selectedWeekdays.insert(weekday)
                print(selectedWeekdays)
            } else {
                selectedWeekdays.remove(weekday)
            }
        }
    }
    
    
}
