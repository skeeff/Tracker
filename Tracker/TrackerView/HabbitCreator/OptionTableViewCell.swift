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
