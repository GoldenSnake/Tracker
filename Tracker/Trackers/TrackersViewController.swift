

import UIKit

final class TrackersViewController: UIViewController {
    
    static let notificationName = NSNotification.Name("AddNewTracker")
    // MARK: - Private Properties
    
    private lazy var trackerStore: TrackerStoreProtocol = {
        TrackerStore(delegate: self, for: currentDate)
    }()
    
    private var currentDate: Date = Date().dayStart
    
    private let emptyStateView: UIView = {
        let view = EmptyStateView()
        let text = "Что будем отслеживать?"
        view.config(with: text)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //collectionView
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let cellIdentifier = "TrackerCell"
    private let headerIdentifier = "Header"
    let params =  GeometricParams(columnCount: 2,
                                  rowCount: 0,
                                  leftInset: 16,
                                  rightInset: 16,
                                  topInset: 12,
                                  bottomInset: 16,
                                  columnSpacing: 10,
                                  rowSpacing: 0)
    
    //NavigationBar
    private let addTrackerButton = UIBarButtonItem()
    private let searchController = UISearchController()
    private let datePicker = UIDatePicker()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        view.addSubview(emptyStateView)
        configureViewState()
        setupCollectionVeiw()
        setupConstraints()
        setupNavigationBar()
        //        collectionView.isHidden = true
        
        configureViewState()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTracker), name: TrackersViewController.notificationName, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: TrackersViewController.notificationName, object: nil)
    }
    
    // MARK: - Private Methods
    
    private func configureViewState() {
        collectionView.isHidden = trackerStore.isEmpty
        emptyStateView.isHidden = !trackerStore.isEmpty
    }
    
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
    
    //NavigationBar
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
        guard let category = notification.object as? TrackerCategory,
              let tracker = category.trackers.first else {return}
        
        trackerStore.addNewTracker(tracker, to: category)
    }
    
    @objc private func addTrackerButtonDidTap() {
        print("Add Tracker Button Tap")
        let viewController = AddTrackerViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date.dayStart
        datePicker.removeFromSuperview()
        
        trackerStore.updateDate(currentDate)
        collectionView.reloadData()
        configureViewState()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        let weekday = Weekday(date: currentDate)
        print("Выбранная дата: \(formattedDate), \(weekday.name)")
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
    //header для категорий
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as? TrackerCategoryHeader else {return UICollectionReusableView()}
        
        header.config(with: trackerStore.sectionName(for: indexPath.section))
        return header
    }
}


// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    // кол-во секций
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
    }
    
    // Количество элементов в коллекции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfItemsInSection(section)
    }
    //Настройка ячейки
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackersCell else {
            return UICollectionViewCell()
        }
        
        let completionStatus = trackerStore.completionStatus(for: indexPath)
        
        cell.config(with: completionStatus.tracker,
                    numberOfCompletions: completionStatus.numberOfCompletions,
                    isCompleted: completionStatus.isCompleted,
                    completionIsEnabled: currentDate <= Date().dayStart)
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    // метод для размера ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.totalInsetWidth
        let cellWidth =  availableWidth / CGFloat(params.columnCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    //отступы для секций в коллекциях insetForSectionAt 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    //минимальный отступ между строками коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //расстояние между столбцами
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.columnSpacing
    }
    
    // header размеры
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 19)
    }
    
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidChangeCompletion(for cell: TrackersCell, to isCompleted: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        trackerStore.changeCompletion(for: indexPath, to: isCompleted)
    }
    
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates({
            if !update.deletedSections.isEmpty {
                collectionView.deleteSections(IndexSet(update.deletedSections))
            }
            if !update.insertedSections.isEmpty {
                collectionView.insertSections(IndexSet(update.insertedSections))
            }
            
            collectionView.insertItems(at: update.insertedIndexes)
            collectionView.deleteItems(at: update.deletedIndexes)
            collectionView.reloadItems(at: update.updatedIndexes)
            
            for move in update.movedIndexes{
                collectionView.moveItem(at: move.from, to: move.to)
            }
        }, completion: nil)
        configureViewState()
    }
}
