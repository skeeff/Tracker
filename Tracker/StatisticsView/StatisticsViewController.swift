import UIKit

final class StatisticsViewController: UIViewController{
    
    private lazy var statisticsLabel: UILabel? = {
        let tempLabel = UILabel()
        tempLabel.text = "Статистика"
        tempLabel.font = .systemFont(ofSize: 34, weight: .bold)
        tempLabel.textColor = .black
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        return tempLabel
    }()
    
    private lazy var placeholderImageView: UIImageView? = {
        let tempImageView = UIImageView()
        tempImageView.image = UIImage(named: "statistics_placeholder")
        tempImageView.translatesAutoresizingMaskIntoConstraints = false
        return tempImageView
    }()
    
    private lazy var placeholderLabel: UILabel? = {
        let tempLabel = UILabel()
        tempLabel.text = "Анализировать пока нечего"
        tempLabel.font = .systemFont(ofSize: 12, weight: .medium)
        tempLabel.textColor = .black
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        return tempLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
        setupPlaceholder()
    }
    
    private func setupLabel(){
        guard let statisticsLabel = statisticsLabel else { return }
        view.addSubview(statisticsLabel)
        NSLayoutConstraint.activate([
            statisticsLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            statisticsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupPlaceholder(){
        guard let placeholderImageView = placeholderImageView,
              let placeholderLabel = placeholderLabel else { return }
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 375),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }
}
