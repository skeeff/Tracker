import UIKit

final class TabBarViewController: UIViewController{
    let tabBarCntrl = UITabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()
        customizeTabBarAppearance()
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
    private func customizeTabBarAppearance() {
           let appearance = UITabBarAppearance()
           
           let separatorHeight: CGFloat = 1
           let separatorColor: UIColor = UIColor(white: 0, alpha: 0.1)
           
           UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: separatorHeight), false, 0.0)
           separatorColor.setFill()
           UIRectFill(CGRect(x: 0, y: 0, width: 1, height: separatorHeight))
           let separatorImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           
           appearance.shadowImage = separatorImage
           appearance.backgroundColor = .white
           
           appearance.shadowColor = .clear
           
           tabBarCntrl.tabBar.standardAppearance = appearance
           if #available(iOS 15.0, *) {
               tabBarCntrl.tabBar.scrollEdgeAppearance = appearance
           }
       }
}
