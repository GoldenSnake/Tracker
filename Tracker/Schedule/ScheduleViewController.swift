
import UIKit

final class ScheduleViewController: UIViewController {
    
    
    // MARK: - Private Properties
    
    private let doneButton = ActionButton(type: .system)
    
    private let scheduleTableView = UITableView()
    
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
        title = "Расписание"
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.ypBlack
        ]
    }
    
    private func setupDoneButton() {
        view.addSubview(doneButton)
        doneButton.setTitle("Готово", for: .normal)
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
        scheduleTableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        
        scheduleTableView.separatorStyle = .none
        scheduleTableView.layer.cornerRadius = 16 // Закругляем углы
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
        // Обработка нажатия на кнопку
        
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as? ScheduleCell else {return UITableViewCell()}
        
        // данные для ячейки
        let weekday = Week.allCases[indexPath.row]
        let isOn = false //состояние переключателя по умолчанию
        cell.configure(with: weekday, isOn: isOn) { isOn in
            // Обработка переключения, например, обновление состояния
            print("\(weekday.name) is \(isOn ? "on" : "off")")
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

