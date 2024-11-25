
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    func setupTabBar() {
        
        let trackersList = TrackersViewController()
        trackersList.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers.tabBarItem.title", comment: "Title for the Trackers tab"),
                                               image: .trackerIconNoActive,
                                               selectedImage: .trackerIconActive)
        let navigationController = UINavigationController(rootViewController: trackersList)
        
        let statistics = StatisticsViewController()
        statistics.tabBarItem = UITabBarItem(title: NSLocalizedString("statistics.tabBarItem.title", comment: "Title for the Statistics tab"),
                                             image: .statisticsIconNoActive,
                                             selectedImage: .statisticsIconActive)
        
        viewControllers = [navigationController, statistics]
        
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
        
    }
    
}
