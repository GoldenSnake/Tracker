import UIKit

extension UITableView {
    func addSeparatorIfNeeded(to cell: UITableViewCell, at indexPath: IndexPath) {
        // Убедитесь, что в ячейке нет уже добавленного разделителя
        for subview in cell.contentView.subviews {
            if subview.tag == 1001 { // Установим уникальный тег для разделителя
                subview.removeFromSuperview()
            }
        }
        
        // Проверяем, является ли это не последней ячейкой в секции
        if indexPath.row != self.numberOfRows(inSection: indexPath.section) - 1 {
            let separator = UIView()
            separator.backgroundColor = .ypGray
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.tag = 1001 // Устанавливаем тег для разделителя
            
            cell.contentView.addSubview(separator)
            
            NSLayoutConstraint.activate([
                separator.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
                separator.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
                separator.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
    }
}
