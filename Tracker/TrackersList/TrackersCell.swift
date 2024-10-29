import UIKit

class TrackersCell: UICollectionViewCell {
    
    
    // MARK: - private
    
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let counterLabel = UILabel()
    private let completeButton = UIButton()
    
    private let cardView = UIView()
    private let circleView = UIView()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCircleVeiw()
        setupCardVeiw()
        setupEmojiLabel()
        setupTitleLabel()
        setupCounterLabel()
        setupCompleteButton()
        setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with tracker: Tracker) {
        cardView.backgroundColor = tracker.color
        completeButton.backgroundColor = tracker.color
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        counterLabel.text = "1 день"
    }
    
    
    // MARK: - private
    
    private func setupCircleVeiw() {
        
        circleView.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        circleView.layer.cornerRadius = 12
        circleView.layer.masksToBounds = true
        circleView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupCardVeiw() {
        addSubview(cardView)
        cardView.backgroundColor = .ypBlue
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(circleView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(emojiLabel)
    }
    
    // Настройка emojiLabel
    private func setupEmojiLabel() {
        emojiLabel.text = "😊"
        emojiLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // Настройка titleLabel
    private func setupTitleLabel() {
        titleLabel.text = "Текст"
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .ypWhite
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // Настройка counterLabel
    private func setupCounterLabel() {
        addSubview(counterLabel)
        
        counterLabel.text = "1 день"
        counterLabel.font = .systemFont(ofSize: 12, weight: .medium)
        counterLabel.textColor = .ypBlack
        counterLabel.textAlignment = .left
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // Настройка completeButton
    private func setupCompleteButton() {
        addSubview(completeButton)
        
        completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
        completeButton.tintColor = .ypWhite
        completeButton.backgroundColor = .ypBlue
        completeButton.layer.masksToBounds = true
        completeButton.layer.cornerRadius = 17
        completeButton.addTarget(self, action: #selector(self.completeButtonDidTap), for: .touchUpInside)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            circleView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            circleView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            circleView.widthAnchor.constraint(equalToConstant: 24),
            circleView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            emojiLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            
            completeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            
            counterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -8),
            counterLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            counterLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
    
    // MARK: - Actions
    @objc
    private func completeButtonDidTap() {
        print("Complete button tapped")
    }
    
}
