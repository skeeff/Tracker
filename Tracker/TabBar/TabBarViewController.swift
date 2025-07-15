import UIKit

final class TabBarViewController: UIViewController{
    let tabBarCntrl = UITabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()
    }
    
    func setUpTabBar(){
        let trackerVC = TrackerViewController()
        trackerVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "tracker_tab_inactive"), tag: 0)
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "statistics_tab_inactive"), tag: 1)
        let controllerArray = [trackerVC, statisticsVC]
        
        tabBarCntrl.viewControllers = controllerArray.map{ UINavigationController.init(rootViewController: $0) }
        addChild(tabBarCntrl)
        view.addSubview(tabBarCntrl.view)
        tabBarCntrl.didMove(toParent: self)
        tabBarCntrl.tabBar.isTranslucent = false
    }
}
