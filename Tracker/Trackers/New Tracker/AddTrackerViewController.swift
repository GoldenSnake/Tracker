
import UIKit

final class AddTrackerViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let regularTrackerButton = ActionButton(type: .system)
    private let irregularTrackerButton = ActionButton(type: .system)
    private let stackView = UIStackView()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        setupStackView()
        setupRegularTrackerButton()
        setupirregularTrackerButton()
        setupConstraints()
        setupNav()
    }
    
    // MARK: - Private Methods
    
    private func setupNav() {
        title = NSLocalizedString("addTrackerView.title", comment: "Title for the tracker creation view")
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.ypBlack
        ]
    }
    
    private func setupRegularTrackerButton(){
        let title = NSLocalizedString("regularTrackerButton.title", comment: "Title for the habit tracker button")
        regularTrackerButton.setTitle(title, for: .normal)
        regularTrackerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        regularTrackerButton.addTarget(self, action: #selector(regularTrackerButtonDidTap), for: .touchUpInside)
        
        regularTrackerButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupirregularTrackerButton(){
        let title = NSLocalizedString("irregularTrackerButton.title", comment: "Title for the irregular event tracker button")
        irregularTrackerButton.setTitle(title, for: .normal)
        irregularTrackerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
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
        let viewController = NewTrackerVC(trackerType: .regular)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func irregularTrackerButtonDidTap() {
        print("irregularTrackerButtonDidTap")
        let viewController = NewTrackerVC(trackerType: .irregular)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
}
