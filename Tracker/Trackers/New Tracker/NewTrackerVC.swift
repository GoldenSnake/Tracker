import UIKit

final class NewTrackerVC: UIViewController {
    
    // MARK: - Private Properties
    
    private let colors: [UIColor] = [
        .blueLilacSelection,
        .blueSelection,
        .cornflowerBlueSelection,
        .deepPinkSelection,
        .deepPurpleSelection,
        .emeraldGreenSelection,
        .greenSelection,
        .lightBlueSelection,
        .lightOrangeSelection,
        .lightPinkSelection,
        .lightPurpleSelection,
        .lightGreenSelection,
        .orangeSelection,
        .orchidPinkSelection,
        .pinkSelection,
        .redSelection,
        .slateBlueSelection,
        .tomatoRedSelection
    ]
    
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🌴", "😪"
    ]
    
    private let cancelButton = ActionButton(type: .system)
    private let createButton = ActionButton(type: .system)
    private let buttonStackView = UIStackView()
    
    private var name: String = ""
    private var categoryName: String = ""
    private var days: Set<Weekday>?
    private var color = UIColor.clear
    private var emoji = ""
    
    private var selectedCells: [Int: IndexPath] = [:]
    
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    
    
    // TableView
    private let tableView = UITableView()
    
    // Collection View
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private enum Constants {
        static let headerHeight: CGFloat = 18
        static let footerHeight: CGFloat = 16
        
        static let headerID = "headerID"
        static let footerID = "footerID"
        
        static let textCellID = "TextCell"
        static let linkCellID = "LinkCell"
        static let emojiCellID = "EmojiCell"
        static let colorCellID = "ColorCell"
    }
    
    private let sectionLayout = GeometricParams(
        columnCount: 6,
        rowCount: 3,
        leftInset: 16,
        rightInset: 16,
        topInset: 24,
        bottomInset: 24,
        columnSpacing: 5,
        rowSpacing: 0
    )
    
    private var cellSize: CGFloat {
        let availableWidth = view.frame.width - sectionLayout.totalInsetWidth
        return availableWidth / CGFloat(sectionLayout.columnCount)
    }
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Init
    
    // тип экрана
    enum TrackerType {
        case regular
        case irregular
    }
    
    private var trackerType: TrackerType
    
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        setupContentView()
        setupScroll()
        setupCancelButton()
        setupCreateButton()
        setupButtonStackView()
        
        configureViewState()
        configureUI()
        
        setupTableView()
        setupCollectionView()
        
        contentView.addSubview(tableView)
        contentView.addSubview(collectionView)
        contentView.addSubview(buttonStackView)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeight()
    }
    
    // MARK: - Private Methods
    
    
    private func setupCancelButton() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.backgroundColor = .ypWhite
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupCreateButton() {
        createButton.setTitle("Сохранить", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureViewState() {
        let daysAreValid = days?.isEmpty == false || trackerType == .irregular
       
        createButton.isEnabled =
        !name.isEmpty &&
        !categoryName.isEmpty &&
        daysAreValid &&
        color != .clear &&
        !emoji.isEmpty
    }
    
    private func setupButtonStackView() {
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.distribution = .fillEqually
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    private func configureUI() {
        
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.ypBlack
        ]
        
        switch trackerType {
        case .regular:
            title = "Новая Привычка"
        case .irregular:
            title = "Нерегулярное событие"
        }
    }
    
    private func setupScroll() {
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //TableView
    
    private func setupTableView() {
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(TextCell.self, forCellReuseIdentifier: Constants.textCellID)
        tableView.register(LinkCell.self, forCellReuseIdentifier: Constants.linkCellID)
        
        // delegate, dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        
        //Constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //CollectionView
    
    private func setupCollectionView() {
        //register
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Constants.headerID)
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: Constants.footerID)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: Constants.colorCellID)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: Constants.emojiCellID)
        //DataSourse & Delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //Constraints
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateTableViewHeight() {
        tableView.layoutIfNeeded()
        tableViewHeightConstraint?.constant = tableView.contentSize.height
    }
    
    private func setupConstraints() {
        let sectionHeight = cellSize * CGFloat(sectionLayout.rowCount) + sectionLayout.totalInsetHeight + Constants.headerHeight
        let totalCollectionHeight = sectionHeight * 2 + Constants.footerHeight
        
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 250)
        tableViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Ограничение высоты contentView
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor, constant: 1),
            
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            collectionView.heightAnchor.constraint(equalToConstant: totalCollectionHeight),
            
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        let tracker = Tracker(id: UUID(), name: name, color: color, emoji: emoji, days: days)
        let category = TrackerCategory(name: categoryName, trackers: [tracker])
        
        NotificationCenter.default.post(name: TrackersViewController.notificationName, object: category)
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension NewTrackerVC: UITableViewDataSource, UITableViewDelegate {
    
    //  количество секций
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // количество ячеек в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch trackerType {
        case .regular:
            return section == 0 ? 1 : 2
        case .irregular:
            return 1
        }
    }
    // Настройка ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return configureTextCell(for: tableView, at: indexPath)
        case 1:
            return configureLinkCell(for: tableView, at: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    private func configureTextCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.textCellID, for: indexPath) as? TextCell else {
            return UITableViewCell()
        }
        tableView.applyCornerRadius(to: cell, at: indexPath)
        cell.configure(placeholder: "Введите название трекера") { [weak self] text in
            self?.name = text
            self?.configureViewState()
        }
        return cell
    }
    
    private func configureLinkCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.linkCellID, for: indexPath) as? LinkCell else {
            return UITableViewCell()
        }
        
        tableView.addSeparatorIfNeeded(to: cell, at: indexPath)
        tableView.applyCornerRadius(to: cell, at: indexPath)
        
        let (title, caption) = getTitleAndCaptionForLinkCell(at: indexPath.row)
        cell.configure(title: title, caption: caption)
        
        return cell
    }
    
    private func getTitleAndCaptionForLinkCell(at row: Int) -> (String, String) {
        switch row {
        case 0:
            return ("Категория", categoryName)
        case 1:
            let caption: String
            if let days, days.count == Weekday.allCases.count {
                caption = "Каждый день"
            } else {
                caption = days?.map { $0.shortName }.joined(separator: ", ") ?? ""
            }
            return ("Расписание", caption)
        default:
            return ("", "")
        }
    }
    
    // MARK: - UITableViewDelegate
    
    // Обработка нажатий на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            let viewModel = CategoriesViewModel()
            viewModel.delegate = self
            let viewController = CategoriesViewController(viewModel: viewModel, currentCategory: categoryName)
            navigationController?.pushViewController(viewController, animated: true)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            let viewController = ScheduleViewController(days: days)
            viewController.onCompletion = { [weak self] result in
                self?.days = result
                self?.tableView.reloadData()
                self?.configureViewState()
            }
            navigationController?.pushViewController(viewController, animated: true)
            
        }
    }
    // высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    // отступы между секциями
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
}


// MARK: - UICollectionViewDataSource

extension NewTrackerVC: UICollectionViewDataSource {
    
    //Кол-во секций в коллекции
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    // кол-во элементов коллекци
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return section == 0 ? emojis.count : colors.count
    }
    
    //Настройка ячейки
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            return configureEmojiCell(collectionView, indexPath: indexPath)
        case 1:
            return configureColorCell(collectionView, indexPath: indexPath)
        default:
            return UICollectionViewCell()
        }
    }
    
    private func configureEmojiCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.emojiCellID, for: indexPath) as? EmojiCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        cell.config(with: emojis[indexPath.item])
        applySelection(to: cell, at: indexPath)
        return cell
    }
    
    private func configureColorCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.colorCellID, for: indexPath) as? ColorCell else {
            return UICollectionViewCell()
        }
        
        cell.prepareForReuse()
        cell.config(with: colors[indexPath.item])
        applySelection(to: cell, at: indexPath)
        return cell
    }
    
    private func applySelection(to cell: UICollectionViewCell, at indexPath: IndexPath) {
        if selectedCells[indexPath.section] == indexPath {
            (cell as? SelectableCell)?.select()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewTrackerVC: UICollectionViewDelegateFlowLayout {
    
    // размер ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellSize, height: cellSize)
    }
    //размер заголовка для каждой секции
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: Constants.headerHeight)
    }
    
    //размер футера для каждой секции
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.frame.width, height: Constants.footerHeight)
        }
        return CGSize(width: 0, height: 0)
    }
    
    //отступы (внутренние поля) для каждой секции.
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: sectionLayout.topInset, left: sectionLayout.leftInset, bottom: sectionLayout.bottomInset, right: sectionLayout.rightInset)
    }
    
    //минимальное расстояние между строками ячеек в секции
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionLayout.rowSpacing
    }
    
    //минимальное расстояние между ячейками в одной строке
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionLayout.columnSpacing
    }
    
}

// MARK: - UICollectionViewDelegate
extension NewTrackerVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerID", for: indexPath) as? SectionHeader else {
                return UICollectionReusableView()
            }
            view.config(with: indexPath.section == 0 ? "Emoji" : "Цвет")
            return view
        } else if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerID", for: indexPath)
            footerView.backgroundColor = .clear
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if let previousIndexPath = selectedCells[indexPath.section],
           let previousCell = collectionView.cellForItem(at: previousIndexPath) as? SelectableCell {
            guard previousIndexPath != indexPath else { return }
            previousCell.deselect()
            collectionView.deselectItem(at: previousIndexPath, animated: true)
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectableCell {
            selectedCells[indexPath.section] = indexPath
            cell.select()
            
            if indexPath.section == 0 {
                emoji = emojis[indexPath.row]
            } else {
                color = colors[indexPath.item]
            }
            configureViewState()
        }
    }
}

// MARK: - CategorySelectionDelegate

extension NewTrackerVC: CategorySelectionDelegate {
    func didSelectCategory(_ name: String) {
        categoryName = name
        tableView.reloadData()
        configureViewState()

        navigationController?.popViewController(animated: true)
    }
}
