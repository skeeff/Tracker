import UIKit

protocol TrackerCellDelegate: AnyObject {
    func toggleCompleteButton(isCompleted: Bool, for trackerID: UUID, completion: @escaping () -> Void)
}

final class TrackerCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "TrackerCell"
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("+", for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 167, height: 90)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var  quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    weak var delegate: TrackerCellDelegate?
    
    private var trackerID: UUID?
    private var isCurrentlyCompleted: Bool = false
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tracker: Tracker, isCompletedForSelectedDate: Bool, daysCompleted: Int) {
        self.trackerID = tracker.id
        self.isCurrentlyCompleted = isCompletedForSelectedDate
        
        trackerLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        cardView.backgroundColor = tracker.color
        addButton.backgroundColor = tracker.color
        
        
        if isCompletedForSelectedDate {
            addButton.setImage(UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
            addButton.alpha = 0.3
            addButton.setTitle(nil, for: .normal)
        } else {
            addButton.setImage(UIImage(systemName:"plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
            addButton.alpha = 1.0
            addButton.setTitle(nil, for: .normal)
        }
        
//        addButton.isUserInteractionEnabled = isInteractionAllowed
        quantityLabel.text = formatDaysString(daysCompleted)
    }
    
    private func setupLayout(){
        contentView.addSubview(cardView)
        contentView.addSubview(addButton)
        contentView.addSubview(quantityLabel)
        cardView.addSubview(trackerLabel)
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        contentView.bringSubviewToFront(addButton)
        
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -58),
            trackerLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            trackerLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            trackerLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 143),
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            addButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 34),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            quantityLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            quantityLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
        ])
    }
    
    @objc private func addButtonTapped(){
        guard addButton.isUserInteractionEnabled, let id = trackerID else { return }
        animateAddButtonTapped()
        
        delegate?.toggleCompleteButton(isCompleted: isCurrentlyCompleted, for: id) { }
    }
    
    private func formatDaysString(_ count: Int) -> String{
        let lastDigit = count % 10
        let lastTwoDigits = count % 100 // 11, 12, 13, 14
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "\(count) дней"
        } else if lastDigit == 1 {
            return "\(count) день"
        } else if lastDigit >= 2 && lastDigit <= 4 {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    private func animateAddButtonTapped(){
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addButton.transform = CGAffineTransform.identity
            }
        }

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackerLabel.text = nil
        emojiLabel.text = nil
        cardView.backgroundColor = nil
        addButton.backgroundColor = nil
        addButton.setTitle(nil, for: .normal)
        addButton.setImage(nil, for: .normal)
        addButton.alpha = 1.0
        addButton.isUserInteractionEnabled = true
        quantityLabel.text = nil
        trackerID = nil
        isCurrentlyCompleted = false
    }
}
