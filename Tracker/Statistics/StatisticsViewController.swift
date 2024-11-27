import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - Private Properties
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        view.layer.borderWidth = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var gradientLayer = CAGradientLayer()
    
    private lazy var completedNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completedCaptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyView: EmptyStateView = {
        let emptyView = EmptyStateView(frame: .zero)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        return emptyView
    }()
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
    }
    
    private let statisticsService: StatisticsServiceProtocol = StatisticsService()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupGradientBorder()
        print(statisticsService.numberOfCompleted)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientToBorder()
    }
    
    // MARK: - Public Methods
    
    func updateContent() {
        let numberOfCompleted = statisticsService.numberOfCompleted
        
        containerView.isHidden = numberOfCompleted == 0
        emptyView.isHidden = numberOfCompleted > 0
        
        if numberOfCompleted == 0 {
            let caption = NSLocalizedString("emptyView.caption.statisticsIsEmpty",
                                            comment: "Caption when there are no statistics yet")
            let image = UIImage(named: "CryingEmoji")
            emptyView.config(with: caption, image: image)
        } else {
            completedNumberLabel.text = String(numberOfCompleted)
            completedCaptionLabel.text = String(format: NSLocalizedString("trackers.completedCount",
                                                                          comment: "Number of completed trackers"), numberOfCompleted)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.addSubview(emptyView)
        view.addSubview(containerView)
        containerView.addSubview(completedNumberLabel)
        containerView.addSubview(completedCaptionLabel)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString("statistics.tabBarItem.title", comment: "Title for the Statistics tab")
        
        view.backgroundColor = .ypWhite
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 90),
            
            completedNumberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            completedNumberLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            completedNumberLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            
            completedCaptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            completedCaptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            completedCaptionLabel.topAnchor.constraint(equalTo: completedNumberLabel.bottomAnchor, constant: 7)
        ])
    }
    
    private func setupGradientBorder() {
        gradientLayer.colors = [
            UIColor(named: "RedSelection")?.cgColor ?? UIColor(),
            UIColor(named: "LightGreenSelection")?.cgColor ?? UIColor(),
            UIColor(named: "BlueSelection")?.cgColor ?? UIColor()
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        containerView.layer.addSublayer(gradientLayer)
    }
    
    private func applyGradientToBorder() {
        gradientLayer.frame = containerView.bounds
        
        let path = UIBezierPath(roundedRect: containerView.bounds.insetBy(dx: 1, dy: 1),
                                cornerRadius: Constants.cornerRadius)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 1
        
        gradientLayer.mask = shapeLayer
    }
}
