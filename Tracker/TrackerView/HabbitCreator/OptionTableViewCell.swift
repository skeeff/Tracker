//import UIKit
//
//final class OptionTableViewCell: UITableViewCell{
//
//    static let reuseIdentifier = "OptionTableViewCell"
//
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
//        label.textColor = .label
//        return label
//    }()
//
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupUI(){
//        accessoryType = .disclosureIndicator
//        selectionStyle = .default
//
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        contentView.addSubview(titleLabel)
//
//
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//
//        ])
//    }
//
//    func configure(with title: String) {
//        titleLabel.text = title
//    }
//}
import UIKit

final class OptionTableViewCell: UITableViewCell {

    static let reuseIdentifier = "OptionTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {

        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        accessoryType = .disclosureIndicator
        selectionStyle = .default

        detailTextLabel?.textColor = .systemGray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
        
    }

    func configure(with title: String) {
        self.textLabel?.text = title
    }
}
