
import UIKit
import CoreData

enum TrackerError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidName
    case decodingErrorInvalidColorHex
    case decodingErrorInvalidEmoji
}

final class TrackerStore {
    private let context:NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    convenience init() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchTrackers() throws -> [Tracker] {
        let fetchRequest = TrackerCoreData.fetchRequest()
        let trackersFromCoreData = try context.fetch(fetchRequest)
        return try trackersFromCoreData.map { try self.tracker(from: $0) }
    }
    
    func addNewTracker(_ newTracker: Tracker){
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: newTracker)
        do {
            try context.save()
            print("Save: \(newTracker.name)")
        } catch {
            print("Error saving new tracker: \(error.localizedDescription)")
        }
    }
    
    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker){
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.colorHex = uiColorMarshalling.hexString(from: tracker.color)
        //        trackerCoreData.days = tracker.days
        trackerCoreData.emoji = tracker.emoji
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else {
            throw TrackerError.decodingErrorInvalidId
        }
        guard let name = trackerCoreData.name else {
            throw TrackerError.decodingErrorInvalidId
        }
        guard let colorHex = trackerCoreData.colorHex else {
            throw TrackerError.decodingErrorInvalidColorHex
        }
        guard let emoji = trackerCoreData.emoji else {
            throw TrackerError.decodingErrorInvalidEmoji
        }
        return Tracker(id: id,
                       name: name,
                       color: uiColorMarshalling.color(from: colorHex),
                       emoji: emoji,
                       days: nil)
    }
}
