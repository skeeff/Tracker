import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerViewControllerTests: XCTestCase {
    

    func test_emptyState_shouldPass() {
        let dataProvider = MockDataProvider()
        let vc = TrackerViewController(dataProvider: dataProvider)
        vc.loadViewIfNeeded()
        assertSnapshot(matching: vc, as: .image)
    }
}

//import XCTest
//import SnapshotTesting
//@testable import Tracker
//
//final class TrackerViewControllerTests: XCTestCase {
//
//    func test_emptyState_looksCorrect() {
//        let dataProvider = MockDataProvider()
//        
//        let vc = TrackerViewController(dataProvider: dataProvider)
//        
//        vc.loadViewIfNeeded()
//        
//        assertSnapshot(matching: vc, as: .image)
//    }
//
//    func test_withTrackers_looksCorrect() {
//        let tracker1 = Tracker(id: UUID(), name: "Ежедневная зарядка", emoji: "🏋️", color: .systemBlue, schedule: [.monday])
//        let tracker2 = Tracker(id: UUID(), name: "Занятия английским", emoji: "📖", color: .systemRed, schedule: [.monday, .wednesday])
//        
//        let category1 = TrackerCategory(category: "Спорт", trackers: [tracker1])
//        let category2 = TrackerCategory(category: "Учёба", trackers: [tracker2])
//        
//        let dataProvider = MockDataProvider(categories: [category1, category2])
//        
//        let vc = TrackerViewController(dataProvider: dataProvider)
//        vc.loadViewIfNeeded()
//        
//        assertSnapshot(matching: vc, as: .image)
//    }
//}
