//
//  CoreDataStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 22/01/2022.
//

import CoreData
import CoreText

final class CoreDataStorageProvider: ObservableObject, StorageProvider {

    private static let storageContainerName = "Finance"

    private let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: Self.storageContainerName)
        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        })
    }

    // MARK: Fetch

    func fetchReport() async throws -> Report {
        let budgetEntities = try fetchBudgetEntities()
        let budgets = budgetEntities.compactMap { return try? Budget.with(budgetEntity: $0) }
        let report = Report.default(with: budgets)
        return report
    }

    func fetch(budgetWith identifier: Budget.ID) async throws -> Budget {
        let budgetEntity = try fetchBudgetEntity(with: identifier)
        return try Budget.with(budgetEntity: budgetEntity)
    }

    // MARK: Add

    func add(budget: Budget) async throws {
        let budgetEntity = BudgetEntity(context: persistentContainer.viewContext)
        setupBudgetEntity(budgetEntity, with: budget)

        try saveOrRollback()
    }

    func add(slice: BudgetSlice, toBudgetWith id: Budget.ID) async throws {
        let budgetEntity = try fetchBudgetEntity(with: id)

        let sliceEntity = BudgetSliceEntity(context: self.persistentContainer.viewContext)
        sliceEntity.budget = budgetEntity
        setupSliceEntity(sliceEntity, with: slice)

        try saveOrRollback()
    }

    // MARK: Delete

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Set<Budget.ID> {
        var deletedBudgetIdentifiers: Set<Budget.ID> = []
        let budgetsEntities = try fetchBudgetEntities()
        budgetsEntities.forEach { budgetEntity in
            if let identifier = budgetEntity.identifier, identifiers.contains(identifier) {
                self.persistentContainer.viewContext.delete(budgetEntity)
                deletedBudgetIdentifiers.insert(identifier)
            }
        }

        try saveOrRollback()
        return deletedBudgetIdentifiers
    }

    func delete(slicesWith identifiers: Set<BudgetSlice.ID>, inBudgetWith id: Budget.ID) async throws {
        let slicesEntities = try fetchBudgetSlicesEntities(forBudgetWith: id)
        slicesEntities.forEach { sliceEntity in
            if let identifier = sliceEntity.identifier, identifiers.contains(identifier) {
                self.persistentContainer.viewContext.delete(sliceEntity)
            }
        }

        try saveOrRollback()
    }

    // MARK: Private fetching methods

    private func fetchBudgetEntities() throws -> [BudgetEntity] {
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()

        do {
            let entities = try persistentContainer.viewContext.fetch(fetchBudgetsRequest)
            return entities
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    private func fetchBudgetEntity(with identifier: Budget.ID) throws -> BudgetEntity {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetEntity.identifier), identifier as CVarArg)
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()
        fetchBudgetsRequest.predicate = predicate

        do {
            guard let budgetEntity = try persistentContainer.viewContext.fetch(fetchBudgetsRequest).first else {
                throw DomainError.storageProvider(error: .budgetEntityNotFound)
            }
            return budgetEntity
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    private func fetchBudgetSlicesEntities(forBudgetWith identifier: Budget.ID) throws -> [BudgetSliceEntity] {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetSliceEntity.budget.identifier), identifier as CVarArg)
        let fetchBudgetSlicesRequest: NSFetchRequest<BudgetSliceEntity> = BudgetSliceEntity.fetchRequest()
        fetchBudgetSlicesRequest.predicate = predicate

        do {
            let entities = try persistentContainer.viewContext.fetch(fetchBudgetSlicesRequest)
            return entities
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    private func fetchBudgetSliceEntity(with identifier: BudgetSlice.ID) throws -> BudgetSliceEntity {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetSliceEntity.identifier), identifier as CVarArg)
        let fetchBudgetSlicesRequest: NSFetchRequest<BudgetSliceEntity> = BudgetSliceEntity.fetchRequest()
        fetchBudgetSlicesRequest.predicate = predicate

        do {
            guard let budgetSliceEntity = try persistentContainer.viewContext.fetch(fetchBudgetSlicesRequest).first else {
                throw DomainError.storageProvider(error: .budgetEntityNotFound)
            }
            return budgetSliceEntity
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    // MARK: Private setup methods

    private func setupBudgetEntity(_ budgetEntity: BudgetEntity, with budget: Budget) {
        budgetEntity.identifier = budget.id
        budgetEntity.name = budget.name
        budgetEntity.slices = NSSet(array: budget.slices.map { slice in
            let sliceEntity = BudgetSliceEntity(context: persistentContainer.viewContext)
            sliceEntity.budget = budgetEntity

            setupSliceEntity(sliceEntity, with: slice)

            return sliceEntity
        })
    }

    private func setupSliceEntity(_ sliceEntity: BudgetSliceEntity, with slice: BudgetSlice) {
        sliceEntity.identifier = slice.id
        sliceEntity.name = slice.name
        sliceEntity.configurationType = slice.configuration.configurationType

        switch slice.configuration {
        case .montly(let amount):
            sliceEntity.amount = NSDecimalNumber(decimal: amount.value)
        case .scheduled(let schedules):
            sliceEntity.schedules = NSSet(array: schedules.map { schedule in
                let scheduledAmountEntry = BudgetSliceScheduledAmountEntity(context: persistentContainer.viewContext)
                scheduledAmountEntry.slice = sliceEntity

                setupSliceScheduleEntity(scheduledAmountEntry, with: schedule)
                return scheduledAmountEntry
            })
        }
    }

    private func setupSliceScheduleEntity(_ scheduledAmountEntry: BudgetSliceScheduledAmountEntity, with schedule: BudgetSlice.Schedule) {
        scheduledAmountEntry.amount = NSDecimalNumber(decimal: schedule.amount.value)
        scheduledAmountEntry.monthIdentifier = schedule.month.id
    }

    // MARK: Private saving methods

    private func saveOrRollback() throws {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }
}

// MARK: Private Extensions

private extension Budget {

    static func with(budgetEntity: BudgetEntity) throws -> Budget {
        guard let identifier = budgetEntity.identifier,
              let name = budgetEntity.name,
              let slices = budgetEntity.slices else {
                  throw DomainError.storageProvider(error: .cannotCreateBudgetWithEntity)
        }

        let budgetSlices = slices
            .compactMap { $0 as? BudgetSliceEntity }
            .compactMap { BudgetSlice.with(budgetSliceEntity: $0) }

        return try Budget(id: identifier, name: name, slices: budgetSlices)
    }
}

private extension BudgetSlice {

    static func with(budgetSliceEntity: BudgetSliceEntity) -> Self? {
        guard let identifier = budgetSliceEntity.identifier,
              let name = budgetSliceEntity.name else {
            return nil
        }

        if let configuration = BudgetSlice.Configuration.with(budgetSliceEntity: budgetSliceEntity) {
            return try? BudgetSlice(id: identifier, name: name, configuration: configuration)
        } else {
            return nil
        }
    }
}

private extension BudgetSlice.Configuration {

    static func with(budgetSliceEntity: BudgetSliceEntity) -> Self? {
        let configurationType = budgetSliceEntity.configurationType
        let monthlyAmount = budgetSliceEntity.amount
        let schedules = budgetSliceEntity.schedules?.compactMap(BudgetSlice.Schedule.with(budgetSliceScheduleEntity:))

        switch (configurationType, monthlyAmount, schedules) {
        case let (0, monthlyAmount?, _):
            return .montly(amount: .value(monthlyAmount.decimalValue))
        case let (1, _, schedules?) where schedules.count > 0:
            return .scheduled(schedules: schedules)
        default:
            return nil
        }
    }

    var configurationType: Int16 {
        switch self {
        case .montly:
            return 0
        case .scheduled:
            return 1
        }
    }
}

private extension BudgetSlice.Schedule {

    static func with(budgetSliceScheduleEntity: NSSet.Element) -> Self? {
        guard let schedule = budgetSliceScheduleEntity as? BudgetSliceScheduledAmountEntity,
              let monthIdentifier = schedule.monthIdentifier, let month = Months.default[monthIdentifier],
              let amount = schedule.amount else {
            return nil
        }

        return .init(amount: .value(amount.decimalValue), month: month)
    }
}
