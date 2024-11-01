import UIKit

extension UITableView {
    
    func applyCornerRadius(to cell: UITableViewCell, at indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16.0
        // Проверяем количество строк в секции
        if self.numberOfRows(inSection: indexPath.section) == 1 {
            // Единственная ячейка в секции
            cell.layer.cornerRadius = cornerRadius
            cell.layer.masksToBounds = true
        } else {
            // Если это первая ячейка
            if indexPath.row == 0 {
                cell.layer.cornerRadius = cornerRadius
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.layer.masksToBounds = true
            }
            // Если это последняя ячейка
            if indexPath.row == self.numberOfRows(inSection: indexPath.section) - 1 {
                cell.layer.cornerRadius = cornerRadius
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.layer.masksToBounds = true
            }
        }
    }
}


