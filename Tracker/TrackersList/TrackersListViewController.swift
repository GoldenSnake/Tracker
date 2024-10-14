

import UIKit

class TrackersListViewController: UIViewController {
    
    // MARK: - Private Properties
    private let addTrackerButton = UIBarButtonItem()
    private let searchController = UISearchController()
    
    private let datePickerButton: UIBarButtonItem = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.preferredDatePickerStyle = .compact
        let button = UIBarButtonItem(customView: datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
        return button
    }()
    
    private let emptyStateView: UIView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
//        let image = UIImageView(image: .star)
//        image.contentMode = .scaleAspectFit
//        image.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(image)
        
//        let label = UILabel()
//        label.text = "Что будем отслеживать?"
//        label.textAlignment = .center
//        label.textColor = .ypBlack
//        label.font = .systemFont(ofSize: 12)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(label)
//        
//        
//        NSLayoutConstraint.activate([
//            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            image.widthAnchor.constraint(equalToConstant: 80),
//            image.heightAnchor.constraint(equalToConstant: 80),
//            
//            label.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
        
        return view
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        setupNavigationBar()
        view.addSubview(emptyStateView)
        setupConstraints()
    }
    
    // MARK: - Private Methods
    
    /// MARK: - NavigationBar
    
    private func setupNavigationBar() {
        setupNavBarItemLeft()
        setupNavBarItemRight()
        setupSearchController()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Трекеры"
    }
    
    private func setupNavBarItemLeft() {
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        addTrackerButton.image = image
        addTrackerButton.tintColor = .ypBlack
        addTrackerButton.target = self
        addTrackerButton.action = #selector(addTrackerButtonDidTap)
        
        navigationItem.leftBarButtonItem = addTrackerButton
    }
    
    private func setupNavBarItemRight() {
        navigationItem.rightBarButtonItem = datePickerButton
    }
    
    private func setupSearchController() {
        searchController.searchBar.placeholder = "Поиск"
        
        navigationItem.searchController = searchController
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    // MARK: - @objc
    
    @objc private func addTrackerButtonDidTap() {
        print("NavBarItem tapped!")
    }
}
