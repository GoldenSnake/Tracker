
import UIKit

final class ScheduleViewController: UIViewController {
    
    
    // MARK: - Private Properties
    
    private let doneButton = ActionButton(type: .system)
    
    private var schedule: [(Weekday, Bool)] = []
    private let cellReuseID = "ScheduleCell"
    
    private let scheduleTableView = UITableView()
    
    var onCompletion: ((Set<Weekday>) -> Void)?
    
    init(days: Set<Weekday>? = nil) {
        let firstWeekday = Calendar.current.firstWeekday
        schedule = (0..<7).compactMap { index in
            let dayIndex = (index + firstWeekday - 1) % 7 + 1
            if let day = Weekday(rawValue: dayIndex) {
                return (day, days?.contains(day) ?? false)
            }
            return nil
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        setupNav()
        setupDoneButton()
        setupTableView()
    }
    
    // MARK: - Private Methods
    
    private func setupNav() {
        title =  NSLocalizedString("schedule", comment: "Title for the schedule view")
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.ypBlack
        ]
    }
    
    private func setupDoneButton() {
        view.addSubview(doneButton)
        let title = NSLocalizedString("doneButton.title", comment: "Title for the done button")
        doneButton.setTitle(title, for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    //TableView
    
    private func setupTableView() {
        view.addSubview(scheduleTableView)
        
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        
        // Регистрация кастомной ячейки
        scheduleTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        scheduleTableView.register(ScheduleCell.self, forCellReuseIdentifier: cellReuseID)
        
        scheduleTableView.separatorStyle = .none
        scheduleTableView.layer.cornerRadius = 16
        scheduleTableView.layer.masksToBounds = true
        
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scheduleTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            scheduleTableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -39)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        let days = Set(schedule.filter{ $0.1 }.map{ $0.0 })
        onCompletion?(days)
        
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Количество строк в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    // Настройка ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as? ScheduleCell else {return UITableViewCell()}
        
        let item = schedule[indexPath.row]
        cell.configure(with: item.0, isOn: item.1) { [weak self] isOn in
            self?.schedule[indexPath.row].1 = isOn
        }
        
        tableView.applyCornerRadius(to: cell, at: indexPath)
        tableView.addSeparatorIfNeeded(to: cell, at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 // Высота ячейки
    }
}

