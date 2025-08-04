import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
//    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    lazy var persistentContainer: NSPersistentContainer = {                     // 1
        let container = NSPersistentContainer(name: "TrackerDB")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in // 3
            if let error = error as NSError? {                              // 4
                print("error occured while loading persistent stores: \(error)")
            }
        })
        return container
    }()
    
//    lazy var trackerCategoryStore: TrackerCategoryStore = {
//        return TrackerCategoryStore(context: persistentContainer.viewContext)
//    }()
//
//    lazy var trackerRecordStore: TrackerRecordStore = {
//        return TrackerRecordStore(context: persistentContainer.viewContext)
//    }()
//
//    lazy var trackerStore: TrackerStore = {
//        return TrackerStore(
//            context: persistentContainer.viewContext,
//            trackerCategoryStore: self.trackerCategoryStore
//        )
//    }()
    
    func saveContext(){
        let context = persistentContainer.viewContext
        if context.hasChanges{
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

