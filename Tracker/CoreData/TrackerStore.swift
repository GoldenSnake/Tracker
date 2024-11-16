
import UIKit
import CoreData

enum TrackerError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidName
    case decodingErrorInvalidColorHex
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidDays
}

struct TrackerStoreUpdate {
    let insertedSections: [Int]
    let deletedSections: [Int]
    let insertedIndexes: [IndexPath]
    let deletedIndexes: [IndexPath]
    let updatedIndexes: [IndexPath]
    let movedIndexes: [(from: IndexPath, to: IndexPath)]
}

struct TrackerCompletion {
    let tracker: Tracker
    let numberOfCompletions: Int
    let isCompleted: Bool
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    var isEmpty: Bool { get }
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func sectionName(for section: Int) -> String
    //    var savedTrackers: [Tracker] { get }
    func addNewTracker(_ tracker: Tracker)
    func deleteTracker(at indexPath: IndexPath)
    
    func completionStatus(for indexPath: IndexPath) -> TrackerCompletion
    
    func updateDate(_ newDate: Date)
}

final class TrackerStore: NSObject {
    
    private weak var delegate: TrackerStoreDelegate?
    private var date: Date
    
    private let context = CoreDataManager.shared.context
    private let uiColorMarshalling = UIColorMarshalling()
    
    private var insertedSections: [Int] = []
    private var deletedSections: [Int] = []
    private var insertedIndexes: [IndexPath] = []
    private var deletedIndexes: [IndexPath] = []
    private var updatedIndexes: [IndexPath] = []
    private var movedIndexes: [(from: IndexPath, to: IndexPath)] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.name", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = fetchPredicate()
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.name",
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(delegate: TrackerStoreDelegate, for date: Date) {
        self.delegate = delegate
        self.date = date
    }
    
    private func fetchPredicate() -> NSPredicate {
        NSPredicate(
            format: """
                    (%K CONTAINS[n] %@) OR (
                        %K == %@ AND (
                            SUBQUERY(%K, $record, $record != nil AND $record.date == %@).@count > 0 OR
                            SUBQUERY(%K, $record, $record != nil).@count == 0
                        )
                    )
                    """,
            #keyPath(TrackerCoreData.days),
            String(Weekday(date: date).rawValue),
            
            #keyPath(TrackerCoreData.days),
            "",
            
            #keyPath(TrackerCoreData.records),
            date as NSDate,
            
            #keyPath(TrackerCoreData.records)
        )
    }
    
    
    private func category() -> TrackerCategoryCoreData {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        let result = try? context.fetch(request)
        if let result,
           !result.isEmpty {
            return result[0]
        } else {
            let category = TrackerCategoryCoreData(context: context)
            category.name = "Общая категория"
            CoreDataManager.shared.saveContext()
            return category
        }
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    var isEmpty: Bool {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            return fetchedObjects.isEmpty
        } else {
            return true
        }
    }
    
    func sectionName(for section: Int) -> String {
        return fetchedResultsController.sections?[section].name ?? ""
    }
    
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    //    var savedTrackers: [Tracker] {
    //        guard
    //            let objects = self.fetchedResultsController.fetchedObjects,
    //            let saveTrackers = try? objects.map({ self.tracker(from: $0) })
    //        else { return [] }
    //        return saveTrackers
    //    }
    
    func addNewTracker(_ tracker: Tracker) {
        let category = category()
        
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.colorHex = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.days = tracker.days?.toRawString() ?? ""
        trackerCoreData.emoji = tracker.emoji
        do {
            try context.save()
            print("Save: \(tracker.name)")
        } catch {
            print("Error saving new tracker: \(error.localizedDescription)")
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        
    }
    
    func completionStatus(for indexPath: IndexPath) -> TrackerCompletion {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        let tracker = Tracker(id: trackerCoreData.id ?? UUID(),
                              name: trackerCoreData.name ?? "",
                              color: uiColorMarshalling.color(from: trackerCoreData.colorHex ?? "#000000"),
                              emoji: trackerCoreData.emoji ?? "",
                              days: Set(rawValue: trackerCoreData.days))
        
        let isCompleted = trackerCoreData.records?.contains { record in
            guard let trackerRecord = record as? TrackerRecordCoreData else { return false }
            return trackerRecord.date == date
        } ?? false
        
        let trackerCompletion = TrackerCompletion(tracker: tracker,
                                                  numberOfCompletions: trackerCoreData.records?.count ?? 0,
                                                  isCompleted: isCompleted)
        return trackerCompletion
    }
    
    func updateDate(_ newDate: Date) {
        date = newDate
        
        fetchedResultsController.fetchRequest.predicate = fetchPredicate()
        try? fetchedResultsController.performFetch()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedSections.removeAll()
        deletedSections.removeAll()
        insertedIndexes.removeAll()
        deletedIndexes.removeAll()
        updatedIndexes.removeAll()
        movedIndexes.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSections.append(sectionIndex)
        case .delete:
            deletedSections.append(sectionIndex)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath {
                deletedIndexes.append(indexPath)
            }
        case .insert:
            if let newIndexPath {
                insertedIndexes.append(newIndexPath)
            }
        case .update:
            if let indexPath {
                updatedIndexes.append(indexPath)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                movedIndexes.append((from: oldIndexPath, to: newIndexPath))
            }
        @unknown default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TrackerStoreUpdate(
            insertedSections: insertedSections,
            deletedSections: deletedSections,
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes,
            updatedIndexes: updatedIndexes,
            movedIndexes: movedIndexes
        )
        delegate?.didUpdate(update)
    }
}
