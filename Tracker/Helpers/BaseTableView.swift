import UIKit

class BaseTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero, style: .plain)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        self.dataSource = self
        self.delegate = self
        
        self.separatorStyle = .none
        self.layer.cornerRadius = 16 // Закругляем углы
        self.layer.masksToBounds = true
        self.backgroundColor = .ypWhite
        self.translatesAutoresizingMaskIntoConstraints = false
        register()
    }
    
    private func register() {
        self.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    // Укажите количество ячеек в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7 // Заглушка, можно перенастроить позже
    }
    
    // Настройка ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .ypBackground
        cell.selectionStyle = .none
        cell.textLabel?.text = "Row \(indexPath.row)" // Заглушка
        
        if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let separator = UIView()
            separator.backgroundColor = .ypGray
            separator.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
                separator.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
//        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
//                    cell.layer.cornerRadius = 16
//                    cell.layer.masksToBounds = true
//        } else {
//            if indexPath.row == 0 {
//                cell.layer.cornerRadius = 16
//                cell.layer.masksToBounds = true
//                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//            }
//            
//            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
//                cell.layer.cornerRadius = 16
//                cell.layer.masksToBounds = true
//                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//            }
//        }
        
        return cell
    }
    
    // высота ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}


