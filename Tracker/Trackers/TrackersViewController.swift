

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Public Methods
    func setCurrentDate(to date: Date) {
        currentDate = date.dayStart
        datePicker.date = currentDate
        
        
        if currentFilter == .today && currentDate != Date().dayStart {
            currentFilter = .all
        }
        
        trackerStore.applyFilter(currentFilter, on: currentDate)
        collectionView.reloadData()
        configureViewState()
    }
    
    static let addTrackerNotificationName = NSNotification.Name("AddNewTracker")
    static let updateTrackerNotificationName = NSNotification.Name("UpdateTracker")
    // MARK: - Private Properties
    
    private lazy var trackerStore: TrackerStoreProtocol = {
        TrackerStore(delegate: self, date: currentDate, filter: currentFilter)
    }()
    
    private var currentDate: Date = Date().dayStart
    private var currentFilter: FilterOptions = .all
    
    private let emptyStateView: EmptyStateView = {
        let view = EmptyStateView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        let title = NSLocalizedString("filter.title", comment: "Filter")
        button.setTitle(title, for: .normal)
        button.backgroundColor = .ypBlue
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        view.addSubview(filterButton)
        setupConstraints()
        setupNavigationBar()
        //                collectionView.isHidden = true
        
        configureViewState()
        
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Private Methods
    
    private func configureViewState() {
        let isFilteredEmpty = trackerStore.isFilteredEmpty
        let isDateEmpty = isFilteredEmpty ? trackerStore.isDateEmpty : false
        
        collectionView.isHidden = isFilteredEmpty
        emptyStateView.isHidden = !isFilteredEmpty
        filterButton.isHidden = isDateEmpty
        
        if isDateEmpty {
            let caption = NSLocalizedString("emptyView.caption.noTrackersAtDate",
                                            comment: "Caption when there are no trackers for a selected date")
            let image = UIImage(named: "Star")
            emptyStateView.config(with: caption, image: image)
        } else if isFilteredEmpty {
            let caption = NSLocalizedString("emptyView.caption.noTrackersMatchFilter",
                                            comment: "Caption when no trackers match the current filter")
            let image = UIImage(named: "MonocleEmoji")
            emptyStateView.config(with: caption, image: image)
        }
        
        let filterTitleColor: UIColor = (currentFilter == .all || currentFilter == .today) ? .ypWhite : .ypRed
        filterButton.setTitleColor(filterTitleColor, for: .normal)
    }
    
    private func setupCollectionVeiw() {
        view.addSubview(collectionView)
        register()
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 50, right: 0)
        
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
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
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
        title = NSLocalizedString("trackers.tabBarItem.title", comment: "Title for the Trackers tab")
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
        searchController.searchBar.placeholder = NSLocalizedString(
            "searchController.searchBar.placeholder",
            comment: "Placeholder for the search bar"
        )
        
        navigationItem.searchController = searchController
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addNewTracker),
            name: TrackersViewController.addTrackerNotificationName,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTracker),
            name: TrackersViewController.updateTrackerNotificationName,
            object: nil
        )
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: TrackersViewController.addTrackerNotificationName,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: TrackersViewController.updateTrackerNotificationName,
            object: nil
        )
    }
    
    // MARK: - Actions
    @objc
    private func updateTracker(_ notification: Notification) {
        guard let category = notification.object as? TrackerCategory,
              let tracker = category.trackers.first else {
            return
        }
        
        trackerStore.updateTracker(tracker, with: category)
    }
    
    @objc
    private func addNewTracker(_ notification: Notification) {
        guard let category = notification.object as? TrackerCategory,
              let tracker = category.trackers.first else {return}
        
        trackerStore.addNewTracker(tracker, to: category)
    }
    
    @objc private func addTrackerButtonDidTap() {
        let viewController = AddTrackerViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date.dayStart
        datePicker.removeFromSuperview()
        
        if currentFilter == .today && currentDate != Date().dayStart {
            currentFilter = .all
        }
        
        trackerStore.applyFilter(currentFilter, on: currentDate)
        collectionView.reloadData()
        configureViewState()
    }
    
    @objc private func filterButtonDidTap() {
        let viewController = FilterViewController()
        viewController.currentFilter = currentFilter
        viewController.onFilterSelected = { [weak self] filter in
            guard let self else { return }
            
            self.currentFilter = filter
            
            if filter == .today {
                self.currentDate = Date().dayStart
                datePicker.date = Date().dayStart
                
            }
            
            self.trackerStore.applyFilter(currentFilter, on: currentDate)
            self.collectionView.reloadData()
            self.configureViewState()
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
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
    
    // контекстное меню
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first else { return nil }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackersCell,
              cell.cardView.frame.contains(cell.convert(point, from: collectionView)) else { return nil }
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, actionProvider: { [weak self] actions in
            guard let self = self else { return nil }
            
            var menuItems: [UIAction] = []
            menuItems.append(self.createPinAction(for: indexPath, isPinned: cell.isPinned))
            menuItems.append(self.createEditAction(for: indexPath))
            menuItems.append(self.createDeleteAction(for: indexPath))
            
            return UIMenu(children: menuItems)
        })
    }
    
    private func createPinAction(for indexPath: IndexPath, isPinned: Bool) -> UIAction {
        let title = isPinned ? NSLocalizedString("contextMenu.unpin.title", comment: "Unpin item") :
        NSLocalizedString("contextMenu.pin.title", comment: "Pin item")
        
        return UIAction(title: title) { [weak self] action in
            guard let self = self else { return }
            if isPinned {
                self.trackerStore.unpinTracker(at: indexPath)
            } else {
                self.trackerStore.pinTracker(at: indexPath)
            }
        }
    }
    
    private func createEditAction(for indexPath: IndexPath) -> UIAction {
        let title = NSLocalizedString("contextMenu.edit.title", comment: "Edit item")
        return UIAction(title: title) { [weak self] action in
            guard let self = self else { return }
            
            let viewController = NewTrackerVC(
                completionStatus: self.trackerStore.completionStatus(for: indexPath),
                categoryName: self.trackerStore.categoryName(for: indexPath)
            )
            
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .formSheet
            present(navigationController, animated: true)
        }
    }
    
    private func createDeleteAction(for indexPath: IndexPath) -> UIAction {
        let title = NSLocalizedString("contextMenu.delete.title", comment: "Delete item")
        return UIAction(title: title, attributes: .destructive) { [weak self] action in
            guard let self = self else { return }
            
            let actionSheetController = UIAlertController(
                title: NSLocalizedString("deleteConfirmation.title",
                                         comment: "Are you sure you want to delete this tracker?"),
                message: nil,
                preferredStyle: .actionSheet
            )
            
            let deleteAction = UIAlertAction(
                title: NSLocalizedString("deleteButton.title",
                                         comment: "Delete button title"),
                style: .destructive
            ) { [weak self] _ in
                self?.trackerStore.deleteTracker(at: indexPath)
            }
            
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("cancelButton.title",
                                         comment: "Cancel button title"),
                style: .cancel,
                handler: nil
            )
            
            actionSheetController.addAction(deleteAction)
            actionSheetController.addAction(cancelAction)
            
            actionSheetController.preferredAction = cancelAction
            
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackersCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        let targetedPreview = UITargetedPreview(view: cell.cardView, parameters: parameters)
        return targetedPreview
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackersCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        let targetedPreview = UITargetedPreview(view: cell.cardView, parameters: parameters)
        return targetedPreview
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
                    completionIsEnabled: currentDate <= Date().dayStart,
                    isPinned: completionStatus.isPinned)
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
        collectionView.performBatchUpdates({
            for move in update.movedIndexes {
                collectionView.reloadItems(at: [move.to])
            }
        }, completion: nil)
        configureViewState()
    }
}
