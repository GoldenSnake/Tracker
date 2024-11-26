
import CoreData

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
    let isPinned: Bool
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    var isEmpty: Bool { get }
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func sectionName(for section: Int) -> String
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategory)
    func updateTracker(_ tracker: Tracker, with category: TrackerCategory)
    func deleteTracker(at indexPath: IndexPath)
    func pinTracker(at indexPath: IndexPath)
    func unpinTracker(at indexPath: IndexPath)
    func completionStatus(for indexPath: IndexPath) -> TrackerCompletion
    func categoryName(for indexPath: IndexPath) -> String
    func applyFilter(_ filter: FilterOptions, on date: Date)
    func changeCompletion(for indexPath: IndexPath, to isCompleted: Bool)
}

final class TrackerStore: NSObject {
    
    private weak var delegate: TrackerStoreDelegate?
    private var date: Date
    private var filter: FilterOptions
    
    private let context = CoreDataManager.shared.context
    private let categoryProvider: TrackerCategoryCoreDataProvider
    
    private var insertedSections: [Int] = []
    private var deletedSections: [Int] = []
    private var insertedIndexes: [IndexPath] = []
    private var deletedIndexes: [IndexPath] = []
    private var updatedIndexes: [IndexPath] = []
    private var movedIndexes: [(from: IndexPath, to: IndexPath)] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category.order", ascending: true),
                                        NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = fetchPredicate()
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.order",
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(delegate: TrackerStoreDelegate, date: Date, filter: FilterOptions, categoryProvider: TrackerCategoryCoreDataProvider? = nil) {
        self.delegate = delegate
        self.date = date
        self.filter = filter
        if let categoryProvider {
            self.categoryProvider = categoryProvider
        } else {
            self.categoryProvider = TrackerCategoryStore(delegate: nil)
        }
    }
    
    private func fetchPredicate() -> NSPredicate {
            switch filter {
            case .all, .today:
                return allTrackersFetchPredicate()
            case .completed:
                return completedTrackersFetchPredicate()
            case .uncompleted:
                return uncompletedTrackersFetchPredicate()
            }
        }
        
        private func allTrackersFetchPredicate() -> NSPredicate {
            let scheduleMatchDate = NSPredicate(
                format: "%K CONTAINS[n] %@",
                #keyPath(TrackerCoreData.days),
                String(Weekday(date: date).rawValue))
            
            let completionMatchDate = NSPredicate(
                format: "SUBQUERY(%K, $record, $record != nil AND $record.date == %@).@count > 0",
                #keyPath(TrackerCoreData.records),
                date as NSDate)
            
            let isIrregular = NSPredicate(
                format: "%K == %@",
                #keyPath(TrackerCoreData.days),
                "")
            
            let isNotCompletedEver = NSPredicate(
                format: "SUBQUERY(%K, $record, $record != nil).@count == 0",
                #keyPath(TrackerCoreData.records))
            
            let isNotCompletedIrregular = NSCompoundPredicate(
                andPredicateWithSubpredicates: [isIrregular, isNotCompletedEver])
            
            let finalPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [scheduleMatchDate, completionMatchDate, isNotCompletedIrregular])
            
            return finalPredicate
        }
        
        private func completedTrackersFetchPredicate() -> NSPredicate {
            let completionMatchDate = NSPredicate(
                format: "SUBQUERY(%K, $record, $record != nil AND $record.date == %@).@count > 0",
                #keyPath(TrackerCoreData.records),
                date as NSDate)
            
            return completionMatchDate
        }
        
        private func uncompletedTrackersFetchPredicate() -> NSPredicate {
            let isNotCompletedAtDate = NSPredicate(
                format: "SUBQUERY(%K, $record, $record != nil AND $record.date == %@).@count == 0",
                #keyPath(TrackerCoreData.records),
                date as NSDate)
            
            let scheduleMatchDate = NSPredicate(
                format: "%K CONTAINS[n] %@",
                #keyPath(TrackerCoreData.days),
                String(Weekday(date: date).rawValue))
            
            let isNotCompletedRegular = NSCompoundPredicate(
                andPredicateWithSubpredicates: [isNotCompletedAtDate, scheduleMatchDate])
            
            let isIrregular = NSPredicate(
                format: "%K == %@",
                #keyPath(TrackerCoreData.days),
                "")
            
            let isNotCompletedEver = NSPredicate(
                format: "SUBQUERY(%K, $record, $record != nil).@count == 0",
                #keyPath(TrackerCoreData.records))
            
            let isNotCompletedIrregular = NSCompoundPredicate(
                andPredicateWithSubpredicates: [isIrregular, isNotCompletedEver])
            
            let finalPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [isNotCompletedRegular, isNotCompletedIrregular])
            
            return finalPredicate
        }
    
    private func fetchTrackerByID(_ id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        return try? context.fetch(fetchRequest).first
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
        let order = fetchedResultsController.sections?[section].name ?? ""
        return categoryProvider.categoryName(from: order)
    }
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategory) {
        let categoryCoreData = categoryProvider.fetchOrCreateCategory(category.name)
        
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.colorHex = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.days = tracker.days?.toRawString() ?? ""
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.category = categoryCoreData
        
        CoreDataManager.shared.saveContext()
    }
    
    func updateTracker(_ tracker: Tracker, with category: TrackerCategory) {
        guard let trackerCoreData = fetchTrackerByID(tracker.id) else { return }
        
        let categoryCoreData = categoryProvider.fetchOrCreateCategory(category.name)
        
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.colorHex = UIColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.days = tracker.days?.toRawString() ?? ""
        
        if trackerCoreData.category?.isPinned ?? false {
            trackerCoreData.categoryBeforePin = categoryCoreData
        } else {
            trackerCoreData.category = categoryCoreData
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        context.delete(trackerCoreData)
        CoreDataManager.shared.saveContext()
    }
    
    func pinTracker(at indexPath: IndexPath) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        guard let category = trackerCoreData.category, !category.isPinned else { return }
        
        let pinnedCategory = categoryProvider.fetchOrCreatePinnedCategory()
        
        trackerCoreData.categoryBeforePin = trackerCoreData.category
        trackerCoreData.category = pinnedCategory
        
        CoreDataManager.shared.saveContext()
    }
    
    func unpinTracker(at indexPath: IndexPath) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        guard let _ = trackerCoreData.categoryBeforePin else { return }
        
        trackerCoreData.category = trackerCoreData.categoryBeforePin
        trackerCoreData.categoryBeforePin = nil
        
        CoreDataManager.shared.saveContext()
    }
    
    
    func completionStatus(for indexPath: IndexPath) -> TrackerCompletion {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        let tracker = Tracker(id: trackerCoreData.id ?? UUID(),
                              name: trackerCoreData.name ?? "",
                              color: UIColorMarshalling.color(from: trackerCoreData.colorHex ?? "#000000"),
                              emoji: trackerCoreData.emoji ?? "",
                              days: Set(rawValue: trackerCoreData.days))
        
        let isCompleted = trackerCoreData.records?.contains { record in
            guard let trackerRecord = record as? TrackerRecordCoreData else { return false }
            return trackerRecord.date == date
        } ?? false
        
        let trackerCompletion = TrackerCompletion(tracker: tracker,
                                                  numberOfCompletions: trackerCoreData.records?.count ?? 0,
                                                  isCompleted: isCompleted,
                                                  isPinned: trackerCoreData.category?.isPinned ?? false)
        return trackerCompletion
    }
    
    func categoryName(for indexPath: IndexPath) -> String {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        
        if trackerCoreData.category?.isPinned ?? false {
            return trackerCoreData.categoryBeforePin?.name ?? ""
        } else {
            return trackerCoreData.category?.name ?? ""
        }
    }
    
    func applyFilter(_ filter: FilterOptions, on date: Date) {
        self.filter = filter
        self.date = date
        
        fetchedResultsController.fetchRequest.predicate = fetchPredicate()
        try? fetchedResultsController.performFetch()
    }
    
    func changeCompletion(for indexPath: IndexPath, to isCompleted: Bool) {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        //Проверяет, существует ли уже запись о выполнении
        let existingRecord = trackerCoreData.records?.first { record in
            if let trackerRecord = record as? TrackerRecordCoreData,
               let trackerDate = trackerRecord.date {
                return trackerDate == date
            } else {
                return false
            }
        }
        
        if isCompleted && existingRecord == nil {
            let trackerRecordCoreData = TrackerRecordCoreData(context: context)
            trackerRecordCoreData.date = date
            trackerRecordCoreData.tracker = trackerCoreData
            
            CoreDataManager.shared.saveContext()
        } else if !isCompleted,
                  let trackerRecordCoreData = existingRecord as? TrackerRecordCoreData {
            context.delete(trackerRecordCoreData)
            CoreDataManager.shared.saveContext()
        }
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
