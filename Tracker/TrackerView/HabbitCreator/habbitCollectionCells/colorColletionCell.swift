import UIKit

final class ColorCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "colorCollectionCell"
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout(){
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
        ])
    }
    func configure(with color: UIColor){
        colorView.backgroundColor = color
        
    }
    
    func setSelected(_ isSelected: Bool, color: UIColor) {
        if isSelected {
            layer.borderWidth = 3
            layer.masksToBounds = true
            layer.cornerRadius = 16
            layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            layer.borderWidth = 0
            layer.borderColor = UIColor.clear.cgColor
        }
    }
}


