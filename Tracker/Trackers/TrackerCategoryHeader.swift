
import UIKit

final class TrackerCategoryHeader: UICollectionReusableView {
    
    private let categoryTitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTitle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTitle(){
        addSubview(categoryTitleLabel)
        categoryTitleLabel.font = .boldSystemFont(ofSize: 19)
        
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            categoryTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoryTitleLabel.topAnchor.constraint(equalTo: topAnchor),
            categoryTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func config(with category: TrackerCategory) {
        categoryTitleLabel.text = category.name
    }
    
}
