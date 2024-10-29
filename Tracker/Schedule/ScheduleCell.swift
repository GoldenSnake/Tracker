
import UIKit

final class ScheduleCell: UITableViewCell {
    
    private let dayLabel = UILabel()
    private let daySwitch = UISwitch()
    
    private var onToggle: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupDayLabel()
        setupDaySwitch()
        
        castom()
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.trailingAnchor.constraint(equalTo: daySwitch.leadingAnchor, constant: -16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with weekday: Week, isOn: Bool, onToggle: @escaping (Bool) -> Void) {
        dayLabel.text = weekday.name
        daySwitch.isOn = isOn
        self.onToggle = onToggle
    }
    
    private func setupDayLabel(){
        contentView.addSubview(dayLabel)
        dayLabel.font = .systemFont(ofSize: 17, weight: .regular)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupDaySwitch(){
        contentView.addSubview(daySwitch)
        daySwitch.onTintColor = .ypBlue
        daySwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func castom() {
        self.backgroundColor = .ypBackground
        self.selectionStyle = .none
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        onToggle?(daySwitch.isOn)
    }
    
}
