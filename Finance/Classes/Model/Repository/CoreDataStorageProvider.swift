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

    // MARK: Report

    func fetchReport() async throws -> Report {
        let budgetEntities = try fetchBudgetEntities()
        let budgets = try budgetEntities.compactMap(Budget.with(budgetEntity:))
        let report = Report.default(with: budgets)
        return report
    }

    // MARK: Budget

    func fetch(budgetWith identifier: Budget.ID) async throws -> Budget {
        let budgetEntity = try fetchBudgetEntity(with: identifier)

        do {
            return try Budget.with(budgetEntity: budgetEntity)
        } catch let error as DomainError {
            throw error
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    func delete(budgetWith identifier: Budget.ID) async throws -> Report {
        if let budgetEntity = try? fetchBudgetEntity(with: identifier) {
            persistentContainer.viewContext.delete(budgetEntity)
        }

        try saveOrRollback()
        return try await fetchReport()
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws -> Report {
        let budgetsEntities = try fetchBudgetEntities()
        budgetsEntities.forEach { budgetEntity in
            if let identifier = budgetEntity.identifier, identifiers.contains(identifier) {
                self.persistentContainer.viewContext.delete(budgetEntity)
            }
        }

        try saveOrRollback()
        return try await fetchReport()
    }

    func add(budget: Budget) async throws -> Report {
        let budgetEntity = BudgetEntity(context: persistentContainer.viewContext)
        setupBudgetEntity(budgetEntity, with: budget)

        try saveOrRollback()
        return try await fetchReport()
    }

    func update(budget: Budget) async throws -> Budget {
        let budgetEntity = try fetchBudgetEntity(with: budget.id)
        budgetEntity.name = budget.name

        let entitySlices = budgetEntity.slices?.compactMap { $0 as? BudgetSliceEntity } ?? []
        entitySlices.forEach { sliceEntity in
            if !budget.slices.contains(where: { $0.id == sliceEntity.identifier }) {
                self.persistentContainer.viewContext.delete(sliceEntity)
            }
        }
        budget.slices.forEach { slice in
            if !entitySlices.contains(where: { $0.identifier == slice.id }) {
                let sliceEntity = BudgetSliceEntity(context: self.persistentContainer.viewContext)
                sliceEntity.budget = budgetEntity
                setupSliceEntity(sliceEntity, with: slice)
            }
        }

        try saveOrRollback()
        return try await fetch(budgetWith: budget.id)
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

                setupSliceScheduledAmountEntity(scheduledAmountEntry, with: schedule)
                return scheduledAmountEntry
            })
        }
    }

    private func setupSliceScheduledAmountEntity(_ scheduledAmountEntry: BudgetSliceScheduledAmountEntity, with schedule: BudgetSlice.ScheduledAmount) {
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
        let schedules = budgetSliceEntity.schedules?.compactMap(BudgetSlice.ScheduledAmount.with(budgetSliceScheduledAmountEntity:))

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

private extension BudgetSlice.ScheduledAmount {

    static func with(budgetSliceScheduledAmountEntity: NSSet.Element) -> Self? {
        guard let schedule = budgetSliceScheduledAmountEntity as? BudgetSliceScheduledAmountEntity,
              let monthIdentifier = schedule.monthIdentifier, let month = Months.default[monthIdentifier],
              let amount = schedule.amount else {
            return nil
        }

        return .init(amount: .value(amount.decimalValue), month: month)
    }
}
