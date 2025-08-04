import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()
    }
    
    func setUpTabBar() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let trackerStore = TrackerStore(
            context: context,
            appDelegate: appDelegate
        )
        let trackerCategoryStore = TrackerCategoryStore(
            trackerStore: trackerStore
        )
        
        let dataProvider = DataProvider(categoryStore: trackerCategoryStore, trackerStore: trackerStore)
        
        let trackerVC = TrackerViewController(dataProvider: dataProvider)
        trackerVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "tracker_tab_inactive"), selectedImage: UIImage(named: "tracker_tab_inactive")?.withTintColor(.systemBlue))
        trackerVC.view.backgroundColor = .systemBackground
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "statistics_tab_inactive"), selectedImage: UIImage(named: "statistics_tab_inactive")?.withTintColor(.systemBlue))
        statisticsVC.view.backgroundColor = .systemBackground
        
        let trackersNC = UINavigationController(rootViewController: trackerVC)
        trackersNC.navigationBar.prefersLargeTitles = true
        trackersNC.navigationBar.barTintColor = .systemBackground
        
        let statisticsNC = UINavigationController(rootViewController: statisticsVC)
        statisticsNC.navigationBar.prefersLargeTitles = true
        statisticsNC.navigationBar.barTintColor = .systemBackground
        
        setViewControllers([trackersNC, statisticsNC], animated: true)
    }
}
