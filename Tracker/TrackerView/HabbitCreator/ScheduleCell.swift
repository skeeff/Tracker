import UIKit

protocol ScheduleCellDelegate: AnyObject {
    func didToggleSwitch(for day: String, isOn: Bool)
}

final class ScheduleCell: UITableViewCell {
    
    static let reuseIdentifier = "ScheduleCell"
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.onTintColor = .systemBlue
        return switchView
    }()
    
    weak var delegate: ScheduleCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        contentView.addSubview(dayLabel)
        contentView.addSubview(switchView)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        switchView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with day: String, isOn: Bool){
        dayLabel.text = day
        switchView.isOn = isOn
    }
    
    @objc func switchValueDidChange(_ sender: UISwitch){
        delegate?.didToggleSwitch(for: dayLabel.text ?? "", isOn: sender.isOn)
    }
}

