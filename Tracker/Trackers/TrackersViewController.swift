

import UIKit

class TrackersViewController: UIViewController {

    static let notificationName = NSNotification.Name("AddNewTracker")
    // MARK: - Private Properties
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    private var completedIds: Set<UUID> = []
    private var allTrackers: [Tracker] = []
    private var completionsCounter: [UUID: Int] = [:]
    
    private let emptyStateView: UIView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //collectionView
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let cellIdentifier = "TrackerCell"
    private let headerIdentifier = "Header"
    let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 10)
    
    //NavigationBar
    private let addTrackerButton = UIBarButtonItem()
    private let searchController = UISearchController()
    private let datePicker = UIDatePicker()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
//        makeMockData()
        view.addSubview(emptyStateView)
        //        updateView()
        
        setupCollectionVeiw()
        setupConstraints()
        setupNavigationBar()
        collectionView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTracker), name: TrackersViewController.notificationName, object: nil)
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self, name: TrackersViewController.notificationName, object: nil)
        }
    
    // MARK: - Private Methods
    
    private func update() {
            let completedIrregulars = Set(
                allTrackers.filter { tracker in
                    !tracker.isRegular &&
                    completedTrackers.first { $0.trackerId == tracker.id } != nil
                }
            )
            completedIds = Set(
                completedTrackers
                    .filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                    .map { $0.trackerId }
            )
            
            let weekday = Weekday(date: currentDate)
            let selectedTrackers = allTrackers.filter { tracker in
                if let days = tracker.days {
                    return days.contains(weekday)
                } else {
                    return completedIds.contains(tracker.id) || !completedIrregulars.contains(tracker)
                }
            }
            categories = selectedTrackers.isEmpty ? [] : [TrackerCategory(name: "Общая категория", trackers: selectedTrackers)]
            
            collectionView.reloadData()
            
            collectionView.isHidden = selectedTrackers.isEmpty
            emptyStateView.isHidden = !selectedTrackers.isEmpty
        }
        
    
    //    private func updateView() {
    //        if trackers.isEmpty {
    //            view.addSubview(emptyStateView)
    //        }
    //    }
    
    private func setupCollectionVeiw() {
        view.addSubview(collectionView)
        register()
        
        //DataSourse and Delegate
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupConstraints() {
        
        //collectionView
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        //emptyStateView
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func register() {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(TrackersCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(TrackerCategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    
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
    
    // MARK: - Actions
    
    @objc
      private func addNewTracker(_ notification: Notification) {
          guard let tracker = notification.object as? Tracker else { return }
          allTrackers.append(tracker)
          update()
      }
    
    @objc private func addTrackerButtonDidTap() {
        print("add tapped!")
        let viewController = AddTrackerViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        datePicker.removeFromSuperview()
        
        update()
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        let weekday = Weekday(date: currentDate)
        print("Выбранная дата: \(formattedDate), \(weekday.name)")
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
    //header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as? TrackerCategoryHeader else {return UICollectionReusableView()}
        
        header.config(with: categories[indexPath.section])
        return header
    }
}


// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    // кол-во секций
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    // Количество элементов в коллекции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //создаем ячейку
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackersCell else {return UICollectionViewCell()}
        cell.prepareForReuse()
        let tracker = categories[indexPath.section].trackers[indexPath.row]
                cell.config(with: tracker,
                            numberOfCompletions: completionsCounter[tracker.id] ?? 0,
                            isCompleted: completedIds.contains(tracker.id),
                            completionIsEnabled: currentDate <= Date())
                cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    // Метод для задания размера ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    //отступы для секций в коллекциях insetForSectionAt 
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: params.leftInset, bottom: 16, right: params.rightInset)
    }
    
    //минимальный отступ между строками коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //расстояние между столбцами
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    // header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 19)
    }
    
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidChangeCompletion(for cell: TrackersCell, to isCompleted: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        
        if isCompleted {
            completedTrackers.append(TrackerRecord(trackerId: tracker.id, date: currentDate))
            completedIds.insert(tracker.id)
            completionsCounter[tracker.id] = (completionsCounter[tracker.id] ?? 0) + 1
        } else {
            completedTrackers.removeAll { $0.trackerId == tracker.id && $0.date == currentDate }
            completedIds.remove(tracker.id)
            if let currentCount = completionsCounter[tracker.id], currentCount > 0 {
                completionsCounter[tracker.id] = currentCount - 1
            }
        }
    }
}
