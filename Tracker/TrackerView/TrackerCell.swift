import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapAddButton(on cell: TrackerCell)
    func didTapRemoveButton(on cell: TrackerCell)
}


final class TrackerCell: UICollectionViewCell {
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        return label
    }()
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .white
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("+", for: .normal)
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
    
    private var counter: Int = 0
    private var isCompletedToday: Bool = false
    
    override init(frame: CGRect){
        super.init(frame: frame)
        contentView.isUserInteractionEnabled = true
        
        contentView.addSubview(cardView)
        contentView.addSubview(addButton)
        contentView.addSubview(quantityLabel)
        cardView.addSubview(trackerLabel)
        cardView.addSubview(emojiLabel)
        contentView.bringSubviewToFront(addButton)
        
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
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
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            addButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 34),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            quantityLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            quantityLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with tracker: Tracker, selectedDate: Date){
        trackerLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        cardView.backgroundColor = tracker.color
        addButton.backgroundColor = tracker.color
        
        let normalizedDate = Calendar.current.startOfDay(for: selectedDate)
        
        if tracker.completedDates.contains(normalizedDate) {
            addButton.setTitle("✓", for: .normal)
            addButton.alpha = 0.3
            addButton.isUserInteractionEnabled = true
        } else {
            addButton.setTitle("+", for: .normal)
            addButton.alpha = 1.0
            addButton.isUserInteractionEnabled = true
        }
        
        isCompletedToday = tracker.completedDates.contains(normalizedDate)
        
        self.counter = tracker.daysCompleted
        let lastDigit = counter % 10
        let lastTwoDigits = counter % 100 // Нужно для исключений 11, 12, 13, 14
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            quantityLabel.text = "\(counter) дней"
        } else if lastDigit == 1 {
            quantityLabel.text = "\(counter) день"
        } else if lastDigit >= 2 && lastDigit <= 4 {
            quantityLabel.text = "\(counter) дня"
        } else {
            quantityLabel.text = "\(counter) дней"
        }
    }
    
    @objc func addButtonTapped(){
        if isCompletedToday {
            delegate?.didTapRemoveButton(on: self)
        } else {
            delegate?.didTapAddButton(on: self)
        }
    }
}
