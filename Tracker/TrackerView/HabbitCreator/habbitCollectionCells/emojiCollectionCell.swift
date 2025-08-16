import UIKit

final class EmojiCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "emojiCollectionCell"
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout(){
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    func configure(with emoji: String){
        emojiLabel.text = emoji
        
    }
    func setSelected(_ isSelected: Bool) {
        if isSelected {
            backgroundColor = UIColor(white: 0, alpha: 0.12)
            layer.cornerRadius = 16
        } else {
            backgroundColor = .clear
            layer.cornerRadius = 0
        }
    }
}


