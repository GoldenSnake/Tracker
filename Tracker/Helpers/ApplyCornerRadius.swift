import UIKit

extension UITableView {
    
    func applyCornerRadius(to cell: UITableViewCell, at indexPath: IndexPath) {
                
        // Проверяем количество строк в секции
        if self.numberOfRows(inSection: indexPath.section) == 1 {
            // Единственная ячейка в секции
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
        } else {
            // Если это первая ячейка
            if indexPath.row == 0 {
                cell.layer.cornerRadius = 16
                cell.layer.masksToBounds = true

                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            // Если это последняя ячейка
            if indexPath.row == self.numberOfRows(inSection: indexPath.section) - 1 {
                cell.layer.cornerRadius = 16
                cell.layer.masksToBounds = true

                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }
    }
}


