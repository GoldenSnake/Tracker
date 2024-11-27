import UIKit

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let cellIdentifier = "TextCell"
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.register(TextCell.self, forCellReuseIdentifier: cellIdentifier)
        
        table.separatorStyle = .none
        table.backgroundColor = .ypWhite
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true

        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var createButton: ActionButton = {
        let button = ActionButton()
        let title = NSLocalizedString("doneButton.title", comment: "Title for the done button")
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(createButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var store: TrackerCategoryStore = {
        TrackerCategoryStore(delegate: nil)
    }()
    
    private var name: String = "" {
        didSet {
            configureViewState()
        }
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        view.addSubview(tableView)
        view.addSubview(createButton)
      
        setupNav()
        setupConstraints()
        configureViewState()
        addHideKeyboardTapGesture()
    }
    
    // MARK: - Private Methods
    
    private func setupNav() {
        title = NSLocalizedString(
                   "newCategoryView.title",
                   comment: "Title for the new category view"
               )
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.ypBlack
        ]
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16),
            
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureViewState() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        createButton.isEnabled = !trimmedName.isEmpty
    }
    
    private func addHideKeyboardTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func createButtonDidTap() {
        store.addCategory(name)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource

extension NewCategoryViewController: UITableViewDataSource {
    
    //  количество секций
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // количество ячеек в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Настройка ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TextCell else {
            return UITableViewCell()
        }
        tableView.applyCornerRadius(to: cell, at: indexPath)
        let placeholder = NSLocalizedString(
                    "newCategoryView.name.placeholder",
                    comment: "Placeholder for the category name input"
                )
        cell.configure(text: "", placeholder: placeholder) { [weak self] text in
            self?.name = text
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewCategoryViewController: UITableViewDelegate {
    
    // Обработка нажатий на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    // высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}

