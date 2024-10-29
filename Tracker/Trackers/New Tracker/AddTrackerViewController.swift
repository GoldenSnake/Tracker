
import UIKit

class AddTrackerViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let regularTrackerButton = UIButton(type: .system)
    private let irregularTrackerButton = UIButton(type: .system)
    private let stackView = UIStackView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        
        setupTitleLabel()
        setupStackView()
        setupRegularTrackerButton()
        setupirregularTrackerButton()
        setupConstraints()
    }
    
    private func setupTitleLabel(){
        view.addSubview(titleLabel)
        
        titleLabel.text = "Создание трекера"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .ypBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupRegularTrackerButton(){
        
        regularTrackerButton.setTitle("Привычка", for: .normal)
        regularTrackerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        regularTrackerButton.setTitleColor(.ypWhite, for: .normal)
        regularTrackerButton.backgroundColor = .ypBlack
        regularTrackerButton.layer.cornerRadius = 16
        
        regularTrackerButton.addTarget(self, action: #selector(regularTrackerButtonDidTap), for: .touchUpInside)
        
        regularTrackerButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupirregularTrackerButton(){
        
        irregularTrackerButton.setTitle("Нерегулярное событие", for: .normal)
        irregularTrackerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        irregularTrackerButton.setTitleColor(.ypWhite, for: .normal)
        irregularTrackerButton.backgroundColor = .ypBlack
        irregularTrackerButton.layer.cornerRadius = 16
        
        irregularTrackerButton.addTarget(self, action: #selector(irregularTrackerButtonDidTap), for: .touchUpInside)
        
        irregularTrackerButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupStackView() {
        view.addSubview(stackView)
    
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(regularTrackerButton)
        stackView.addArrangedSubview(irregularTrackerButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 114),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            regularTrackerButton.heightAnchor.constraint(equalToConstant: 60),
            irregularTrackerButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func regularTrackerButtonDidTap() {
        print("regularTrackerButtonDidTap")
//        let vc = AddTrackerViewController()
//        vc.modalPresentationStyle = .formSheet
//        present(vc, animated: true)
    }
    
    @objc private func irregularTrackerButtonDidTap() {
        print("irregularTrackerButtonDidTap")
//        let vc = AddTrackerViewController()
//        vc.modalPresentationStyle = .formSheet
//        present(vc, animated: true)
    }
    
    
    
}
