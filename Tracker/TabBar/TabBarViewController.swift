import UIKit

final class TabBarViewController: UIViewController{
    let tabBar = UITabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerVC = TrackerViewController()
        trackerVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "tracker_tab_inactive"), tag: 0)
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "statistics_tab_inactive"), tag: 1)
        
        let controllerArray = [trackerVC, statisticsVC]
        
        tabBar.viewControllers = controllerArray.map{ UINavigationController.init(rootViewController: $0) }
        
        self.view.addSubview(tabBar.view)
    }
}
