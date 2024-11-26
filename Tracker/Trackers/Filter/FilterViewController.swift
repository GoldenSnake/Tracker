import UIKit

final class FilterViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        
        table.separatorStyle = .none
        table.backgroundColor = .ypWhite
        table.layer.cornerRadius = 16
        table.layer.masksToBounds = true
        
        table.register(FilterCell.self, forCellReuseIdentifier: cellReuseID)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let allFilters: [FilterOptions] = FilterOptions.allCases
    private let cellReuseID = "FilterCell"

    var onFilterSelected: ((FilterOptions) -> Void)?
    var currentFilter: FilterOptions?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        title = NSLocalizedString("filter.title", comment: "Filter")
    }
}

// MARK: - UITableViewDataSource

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as? FilterCell else {
            return UITableViewCell()
        }
        tableView.applyCornerRadius(to: cell, at: indexPath)
        
        tableView.addSeparatorIfNeeded(to: cell, at: indexPath)

        let item = allFilters[indexPath.row]
        let isSelected = currentFilter == item
        cell.configure(name: item.localizedTitle, isSelected: isSelected)

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = allFilters[indexPath.row]
        onFilterSelected?(selectedFilter)
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate

extension FilterViewController: UITableViewDelegate {
    
    // высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
}
