import UIKit

extension UITableView {
    
    func applyCornerRadius(to cell: UITableViewCell, at indexPath: IndexPath) {
        
        cell.layer.cornerRadius = 0
        cell.layer.masksToBounds = false

        let numberOfRows = self.numberOfRows(inSection: indexPath.section)
        let isFirstRow = indexPath.row == 0
        let isLastRow = indexPath.row == numberOfRows - 1
    
        if isFirstRow || isLastRow {
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            
            var corners: CACornerMask = []
            if isFirstRow {
                corners.insert(.layerMinXMinYCorner)
                corners.insert(.layerMaxXMinYCorner)
            }
            if isLastRow {
                corners.insert(.layerMinXMaxYCorner)
                corners.insert(.layerMaxXMaxYCorner)
            }
            cell.layer.maskedCorners = corners
        } else {
            cell.layer.maskedCorners = []
        }
        
    }
    
}


