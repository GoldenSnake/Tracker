import UIKit

final class NewTrackerVC: UIViewController {
    
    // MARK: - Private Properties
    
    private let cancelButton = ActionButton(type: .system)
    private let createButton = ActionButton(type: .system)
    private let buttonStackView = UIStackView()
    
    private var name: String = ""
    private var days: Set<Weekday>?
    
    // TableView
    private let tableView = UITableView()
    private let textCellID = "TextCell"
    private let linkCellID = "LinkCell"
    
    // MARK: - Init
    
    // Определяем тип экрана
    enum TrackerType {
        case regular // Привычка
        case irregular // Нерегулярное событие
    }
    
    private var trackerType: TrackerType
    
    // Инициализатор для передачи типа экрана
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
        
        view.backgroundColor = .white
        
        setupCancelButton()
        setupCreateButton()
        setupButtonStackView()
        configureViewState()
        
        configureUI()
        
        setupTableView()
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
           createButton.isEnabled = !name.isEmpty && daysAreValid
       }
    
    private func setupButtonStackView() {
        view.addSubview(buttonStackView)
        
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 8
        buttonStackView.distribution = .fillEqually
        
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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
    
    //TableView
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(TextCell.self, forCellReuseIdentifier: textCellID)
        tableView.register(LinkCell.self, forCellReuseIdentifier: linkCellID)
        
        // delegate, dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16 // Закругляем углы
        tableView.layer.masksToBounds = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        // Обработка нажатия
    }
}

extension NewTrackerVC: UITableViewDataSource, UITableViewDelegate {
    
    // Укажите количество секций (по умолчанию 1)
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Укажите количество ячеек в секции
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
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: textCellID, for: indexPath) as? TextCell else {
                        return UITableViewCell()
                    }
                    cell.onTextChange = { [weak self] text in
                        self?.name = text
                        self?.configureViewState()
                    }
                    return cell
                    
                case 1:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: linkCellID, for: indexPath) as? LinkCell else {
                        return UITableViewCell()
                    }
                    if indexPath.row == 0 {
                        cell.configure(title: "Категория", caption: "Общая категория")
                    } else if indexPath.row == 1 {
                        var caption = ""
                        if let days {
                            if days.count == Weekday.allCases.count {
                                caption = "Каждый день"
                            } else {
                                let shortNames = days.map { $0.shortName }
                                caption = shortNames.joined(separator: ", ")
                            }
                        }
                        cell.configure(title: "Расписание", caption: caption)
                    }
                    return cell
                    
                default:
                    return UITableViewCell()
                }
    }
//
//        switch trackerType {
//        case .regular:
//            if indexPath.section == 0 {
//                guard let textCell = tableView.dequeueReusableCell(withIdentifier: textCellID, for: indexPath) as? TextCell else {return UITableViewCell()}
//                tableView.applyCornerRadius(to: textCell, at: indexPath)
//                textCell.onTextChange = { [weak self] text in
//                    self?.name = text
//                    self?.configureViewState()
//                }
//                return textCell
//            } else if indexPath.row == 0 {
//                guard let linkCell = tableView.dequeueReusableCell(withIdentifier: linkCellID, for: indexPath) as? LinkCell else {return UITableViewCell()}
//                linkCell.configure(title: "Категория")
//                tableView.addSeparatorIfNeeded(to: linkCell , at: indexPath)
//                tableView.applyCornerRadius(to: linkCell, at: indexPath)
//                return linkCell
//            } else {
//                guard let linkCell = tableView.dequeueReusableCell(withIdentifier: linkCellID, for: indexPath) as? LinkCell else {return UITableViewCell()}
//                linkCell.configure(title: "Расписание")
//                tableView.addSeparatorIfNeeded(to: linkCell , at: indexPath)
//                tableView.applyCornerRadius(to: linkCell, at: indexPath)
//                return linkCell
//            }
//        case .irregular:
//            if indexPath.section == 0 {
//                guard let textCell = tableView.dequeueReusableCell(withIdentifier: textCellID, for: indexPath) as? TextCell else {return UITableViewCell()}
//                tableView.applyCornerRadius(to: textCell, at: indexPath)
//                textCell.onTextChange = { [weak self] text in
//                    self?.name = text
//                    self?.configureViewState()
//                }
//                return textCell
//            } else {
//                guard let linkCell = tableView.dequeueReusableCell(withIdentifier: linkCellID, for: indexPath) as? LinkCell else {return UITableViewCell()}
//                linkCell.configure(title: "Категория")
//                tableView.addSeparatorIfNeeded(to: linkCell , at: indexPath)
//                tableView.applyCornerRadius(to: linkCell, at: indexPath)
//                return linkCell
//            }
//        }
        
        
   
    
    // MARK: - UITableViewDelegate
    
    // Обработка нажатий на ячейку (опционально)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 1 {
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



