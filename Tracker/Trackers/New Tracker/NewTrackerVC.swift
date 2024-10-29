import UIKit

class NewTrackerVC: UIViewController {
    
    // MARK: - Private Properties
    
    private let titleLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    private let buttonStackView = UIStackView()
    
    private let scheduleButton = UIButton(type: .system)
    
    // TableView
    private let tableView = UITableView()
    
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
        setupTitleLabel()
        setupCancelButton()
        setupCreateButton()
        setupButtonStackView()
        
        setupScheduleButton()
        
        configureUI()
        
        setupTableView()
    }
    
    // MARK: - Private Methods
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 16
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
        createButton.setTitleColor(.ypWhite, for: .normal)
        createButton.layer.masksToBounds = true
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = .ypBlack
        
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
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
    
    
    private func setupScheduleButton() {
        view.addSubview(scheduleButton)
        scheduleButton.setTitle("Расписание", for: .normal)
        scheduleButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            scheduleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scheduleButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        ])
    }
    
    
    private func configureUI() {
        switch trackerType {
        case .regular:
            titleLabel.text = "Новая Привычка"
            scheduleButton.isHidden = false
        case .irregular:
            titleLabel.text = "Нерегулярное событие"
            scheduleButton.isHidden = true
        }
    }
    
    //TableView
    
    private func setupTableView() {
        view.addSubview(tableView)
        register()
        setupTableConstraints()
        
        // delegate, dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    private func register() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupTableConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    
    // MARK: - Actions
    
    @objc private func scheduleButtonTapped() {
        // Обработка нажатия на кнопку "Расписание"
    }
    
    @objc private func cancelButtonTapped() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
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
    
    // Укажите количество строк в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    // Настройка ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Ячейка \(indexPath.row + 1)" // настройте текст для каждой ячейки
        return cell
    }
    
    // Обработка нажатий на ячейку (опционально)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Нажата ячейка \(indexPath.row + 1)")
    }
}
