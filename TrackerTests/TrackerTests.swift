import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackers() throws {
        //очистка списка трекеров
        let store = TrackerStore()
        
        do {
            try store.deleteAll()
        } catch {
            XCTFail("Failed to clear Core Data: \(error.localizedDescription)")
            return
        }
        //создание тестовых трекеров
        let category = TrackerCategory(name: "Test", trackers: [])
        
        let days: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        let regularTracker = Tracker(id: UUID(), name: "Regular", color: .greenSelection, emoji: "😻", days: days)
        store.addNewTracker(regularTracker, to: category)
        
        let irregularTracker = Tracker(id: UUID(), name: "Irregular", color: .deepPurpleSelection, emoji: "🍔", days: nil)
        store.addNewTracker(irregularTracker, to: category)
        
        let TabBarViewController = TabBarController()
        TabBarViewController.loadViewIfNeeded()
        
        guard let navigationController = TabBarViewController.viewControllers?.first as? UINavigationController,
              let trackersVC = navigationController.viewControllers.first as? TrackersViewController else {
            XCTFail("Unexpected Tab Bar configuration")
            return
        }
        
        let dateComponents = DateComponents(year: 2024, month: 10, day: 25)
        guard let date = Calendar.current.date(from: dateComponents) else {
            XCTFail("Failed to create date")
            return
        }
        
        trackersVC.setCurrentDate(to: date)
        
        assertSnapshot(of: TabBarViewController, as: .image(traits: .init(userInterfaceStyle: .light)))
        assertSnapshot(of: TabBarViewController, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
