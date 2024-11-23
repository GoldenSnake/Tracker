

import UIKit

final class OnboardingPageViewController: UIViewController {
    
    private lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: 32)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var skipButton: ActionButton = {
    let button = ActionButton(type: .system)
        button.addTarget(self, action: #selector(skipButtonDidTap), for: .touchUpInside)
        button.setTitle("Вот это технологии!", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var labelOffset: CGFloat = {
           return UIScreen.main.bounds.width <= 320 ? 24 : 64
       }()
       private var onCompletion: (() -> Void)?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundImage)
        view.addSubview(textLabel)
        view.addSubview(skipButton)
        
        setupConstraints()
    }
    
    // MARK: - Private Methods
       func config(text: String, background: UIImage, onCompletion: (() -> Void)?) {
           backgroundImage.image = background
           textLabel.text = text
           self.onCompletion = onCompletion
       }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: labelOffset),
            
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            skipButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @objc private func skipButtonDidTap(_ sender: UIButton) {
        onCompletion?()
    }
    
}
