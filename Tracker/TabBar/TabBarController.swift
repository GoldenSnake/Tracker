
import UIKit

class TabBarController: UITabBarController {
    private var border: CALayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabBar()
    }
    
    func setupTabBar() {
        
        let trackersList = TrackersViewController()
        trackersList.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers.tabBarItem.title", comment: "Title for the Trackers tab"),
                                               image: .trackerIconNoActive,
                                               selectedImage: .trackerIconActive)
        let trackersContainer = UINavigationController(rootViewController: trackersList)
        
        let statistics = StatisticsViewController()
        statistics.tabBarItem = UITabBarItem(title: NSLocalizedString("statistics.tabBarItem.title", comment: "Title for the Statistics tab"),
                                             image: .statisticsIconNoActive,
                                             selectedImage: .statisticsIconActive)
        let statisticsContainer = UINavigationController(rootViewController: statistics)
        
        viewControllers = [trackersContainer, statisticsContainer]
        
        setupTopBorder()
            }

            override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                if let border {
                    border.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
                }
            }

            override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
                super.traitCollectionDidChange(previousTraitCollection)
                if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
                    border?.backgroundColor = UIColor.ypGrayDark.cgColor
                }
            }

            private func setupTopBorder() {
                let border = CALayer()
                border.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
                border.backgroundColor = UIColor.ypGrayDark.cgColor
                tabBar.layer.addSublayer(border)
                self.border = border
        
    }
    
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController,
           let statisticsView = navigationController.topViewController as? StatisticsViewController {
            statisticsView.updateContent()
        }
    }
}
