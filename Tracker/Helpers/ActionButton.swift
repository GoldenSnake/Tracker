
import UIKit

final class ActionButton: UIButton {
    
    override var isEnabled: Bool {
            didSet {
                setBackgroundColor()
            }
        }
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        setupStyle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }
    
    private func setupStyle() {
        self.setTitleColor(.ypWhite, for: .normal)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        self.backgroundColor = .ypBlack
    }
    
    private func setBackgroundColor() {
        self.backgroundColor = isEnabled ? .ypBlack : .ypGray
    }
}
