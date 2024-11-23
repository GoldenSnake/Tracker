import UIKit

final class CategoriesViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var viewModel: CategoriesViewModelProtocol
    
    private let cellIdentifier = "CategoriesCell"
    private let currentCategory: String
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        
        table.separatorStyle = .none
        table.backgroundColor = .ypWhite
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        
        table.register(CategoryCell.self, forCellReuseIdentifier: cellIdentifier)
        
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var addCategoryButton: ActionButton = {
        let button = ActionButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.addTarget(self, action: #selector(addCategoryButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var emptyView: UIView = {
        let text = "Привычки и события можно \n объединить по смыслу"
        let emptyView = EmptyStateView()
        emptyView.config(with: text)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        return emptyView
    }()
    
    // MARK: - View Life Cycle
    
    init(viewModel: CategoriesViewModelProtocol, currentCategory: String) {
        self.viewModel = viewModel
        self.currentCategory = currentCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        view.addSubview(emptyView)
        
        setupNav()
        setupConstraints()
        setupBindings()
        configureViewState()
    }
    
    // MARK: - Private Methods
    
    private func configureViewState() {
        tableView.isHidden = viewModel.categoriesIsEmpty
        emptyView.isHidden = !viewModel.categoriesIsEmpty
    }
    
    private func setupNav() {
        title = "Категория"
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
            NSAttributedString.Key.foregroundColor: UIColor.ypBlack
        ]
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupBindings() {
        viewModel.onDataChanged = { [weak self] in
            guard let self else { return }
            tableView.reloadData()
            configureViewState()
        }
    }
    
    // MARK: - Actions
    @objc func addCategoryButtonDidTap(_ sender: UIButton) {
        navigationController?.pushViewController(NewCategoryViewController(), animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    //кол-во элементов в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories(section)
    }
    // Настройка ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        tableView.applyCornerRadius(to: cell, at: indexPath)
        
        tableView.addSeparatorIfNeeded(to: cell, at: indexPath)
        
        let category = viewModel.category(at: indexPath)
        cell.configure(name: category.name, isSelected: category.name == currentCategory)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    
    // Обработка нажатий на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(indexPath: indexPath)
    }
    
    // высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}
