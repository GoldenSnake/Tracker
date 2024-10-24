

import UIKit

class TrackersViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private let addTrackerButton = UIBarButtonItem()
    private let searchController = UISearchController()
    
   private let datePicker = UIDatePicker()
    
    private let emptyStateView: UIView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
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
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy" // Формат даты
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
}
