//
//  CoreDataStorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 22/01/2022.
//

import CoreData
import CoreText

final class CoreDataStorageProvider: StorageProvider {

    private static let storageContainerName = "Finance"
    private static let overviewIdentifier = UUID.init()
    private static let overviewYear = 2022

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

    func fetchTransactions(year: Int) async throws -> [Transaction] {
        let entities = try fetchTransactionEntities(year: year)
        return try entities.compactMap { try Transaction.with(transactionEntity: $0) }
    }

    func fetchBudgets(year: Int) async throws -> [Budget] {
        let budgetEntities = try fetchBudgetEntities(year: year)
        return budgetEntities.compactMap { return try? Budget.with(budgetEntity: $0) }
    }

    // MARK: Add

    func add(transaction: Transaction) async throws {
        let transactionEntity = TransactionEntity(context: self.persistentContainer.viewContext)
        setupTransactionEntity(transactionEntity, with: transaction)

        try saveOrRollback()
    }

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

    func delete(transactionsWith identifiers: Set<Transaction.ID>) async throws {
        let transactionsEntities = try fetchTransactionEntities()
        transactionsEntities.forEach { transactionEntity in
            if let identifier = transactionEntity.identifier, identifiers.contains(identifier) {
                self.persistentContainer.viewContext.delete(transactionEntity)
            }
        }

        try saveOrRollback()
    }

    func delete(budgetsWith identifiers: Set<Budget.ID>) async throws {
        let budgetsEntities = try fetchBudgetEntities()
        budgetsEntities.forEach { budgetEntity in
            if let identifier = budgetEntity.identifier, identifiers.contains(identifier) {
                self.persistentContainer.viewContext.delete(budgetEntity)
            }
        }

        try saveOrRollback()
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

    // MARK: Update

    func update(name: String, iconSystemName: String, inBudgetWith id: Budget.ID) async throws {
        let budgetEntity = try fetchBudgetEntity(with: id)
        budgetEntity.name = name
        budgetEntity.systemIconName = iconSystemName

        try saveOrRollback()
    }

    // MARK: - Private fetching methods

    private func fetchBudgetEntities(year: Int? = nil) throws -> [BudgetEntity] {
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()

        if let year = year {
            let predicate = NSPredicate(format: "%K == %i", #keyPath(BudgetEntity.year), year as CVarArg)
            fetchBudgetsRequest.predicate = predicate
        }

        do {
            let entities = try persistentContainer.viewContext.fetch(fetchBudgetsRequest)
            return entities
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    private func fetchBudgetEntity(with identifier: Budget.ID) throws -> BudgetEntity {
        let fetchBudgetsRequest: NSFetchRequest<BudgetEntity> = BudgetEntity.fetchRequest()

        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetEntity.identifier), identifier as CVarArg)
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
        let fetchBudgetSlicesRequest: NSFetchRequest<BudgetSliceEntity> = BudgetSliceEntity.fetchRequest()

        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetSliceEntity.budget.identifier), identifier as CVarArg)
        fetchBudgetSlicesRequest.predicate = predicate

        do {
            return try persistentContainer.viewContext.fetch(fetchBudgetSlicesRequest)
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    private func fetchBudgetSliceEntity(with identifier: BudgetSlice.ID) throws -> BudgetSliceEntity {
        let fetchBudgetSlicesRequest: NSFetchRequest<BudgetSliceEntity> = BudgetSliceEntity.fetchRequest()

        let predicate = NSPredicate(format: "%K == %@", #keyPath(BudgetSliceEntity.identifier), identifier as CVarArg)
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

    private func fetchTransactionEntities(year: Int? = nil) throws -> [TransactionEntity] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()

        if let year = year {
            if let startDate = Date.with(year: year, month: 1, day: 1),
               let endDate = Date.with(year: year, month: 12, day: 31) {
                let predicate = NSPredicate(format: "date >= %@ && date <= %@", startDate as NSDate, endDate as NSDate)
                request.predicate = predicate
            }
        }

        do {
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            throw DomainError.storageProvider(error: .underlying(error: error))
        }
    }

    // MARK: - Private setup methods

    private func setupTransactionEntity(_ transactionEntity: TransactionEntity, with transaction: Transaction) {
        transactionEntity.identifier = transaction.id
        transactionEntity.date = transaction.date
        transactionEntity.contentDescription = transaction.description

        transactionEntity.amounts = NSSet(array: transaction.amounts.map { amount in
            let amountEntity = TransactionAmountEntity(context: persistentContainer.viewContext)
            amountEntity.transaction = transactionEntity

            setupTransactionAmountEntity(amountEntity, with: amount)

            return amountEntity
        })
    }

    private func setupTransactionAmountEntity(_ transactionAmountEntity: TransactionAmountEntity, with amount: Transaction.Amount) {
        transactionAmountEntity.amount = NSDecimalNumber(decimal: amount.amount.value)
        transactionAmountEntity.budgetIdentifier = amount.budgetIdentifier
        transactionAmountEntity.sliceIdentifier = amount.sliceIdentifier

        switch amount.budgetKind {
        case .expense:
            transactionAmountEntity.budgetKind = "expense"
        case .income:
            transactionAmountEntity.budgetKind = "income"
        }
    }

    private func setupBudgetEntity(_ budgetEntity: BudgetEntity, with budget: Budget) {
        budgetEntity.identifier = budget.id
        budgetEntity.year = Int64(budget.year)
        budgetEntity.name = budget.name
        budgetEntity.systemIconName = budget.icon.rawValue

        switch budget.kind {
        case .expense:
            budgetEntity.kind = "expense"
        case .income:
            budgetEntity.kind = "income"
        }

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
        case .monthly(let amount):
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
        scheduledAmountEntry.month = Int16(schedule.month)
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
              let kind = budgetEntity.kind,
              let name = budgetEntity.name,
              let systemIconName = budgetEntity.systemIconName,
              let icon = SystemIcon(rawValue: systemIconName),
              let slices = budgetEntity.slices else {
                  throw DomainError.storageProvider(error: .cannotCreateBudgetWithEntity)
        }

        let year = Int(budgetEntity.year)

        let budgetKind: Budget.Kind = {
            switch kind {
            case "income":
                return .income
            case "epxense":
                return .expense
            default:
                return .expense
            }
        }()

        let budgetSlices = try slices
            .compactMap { $0 as? BudgetSliceEntity }
            .compactMap { try BudgetSlice.with(budgetSliceEntity: $0) }

        return try Budget(id: identifier, year: year, kind: budgetKind, name: name, icon: icon, slices: budgetSlices)
    }
}

private extension BudgetSlice {

    static func with(budgetSliceEntity: BudgetSliceEntity) throws -> Self? {
        guard let identifier = budgetSliceEntity.identifier,
              let name = budgetSliceEntity.name else {
            return nil
        }

        if let configuration = try BudgetSlice.Configuration.with(budgetSliceEntity: budgetSliceEntity) {
            return try? BudgetSlice(id: identifier, name: name, configuration: configuration)
        } else {
            return nil
        }
    }
}

private extension BudgetSlice.Configuration {

    static func with(budgetSliceEntity: BudgetSliceEntity) throws -> Self? {
        let configurationType = budgetSliceEntity.configurationType
        let monthlyAmount = budgetSliceEntity.amount
        let schedules = try budgetSliceEntity.schedules?
            .compactMap({ $0 as? BudgetSliceScheduledAmountEntity })
            .compactMap(BudgetSlice.Schedule.with(budgetSliceScheduleEntity:))

        switch (configurationType, monthlyAmount, schedules) {
        case let (0, monthlyAmount?, _):
            return .monthly(amount: .value(monthlyAmount.decimalValue))
        case let (1, _, schedules?) where schedules.count > 0:
            return .scheduled(schedules: schedules)
        default:
            return nil
        }
    }

    var configurationType: Int16 {
        switch self {
        case .monthly:
            return 0
        case .scheduled:
            return 1
        }
    }
}

private extension BudgetSlice.Schedule {

    static func with(budgetSliceScheduleEntity: BudgetSliceScheduledAmountEntity) throws -> Self? {
        guard let amount = budgetSliceScheduleEntity.amount else {
            return nil
        }
        let month = Int(budgetSliceScheduleEntity.month)
        return try .init(amount: .value(amount.decimalValue), month: month)
    }
}

private extension Transaction {

    static func with(transactionEntity: TransactionEntity) throws -> Self? {
        guard let identifier = transactionEntity.identifier,
              let date = transactionEntity.date,
              let amounts = try transactionEntity.amounts?
                .compactMap({ $0 as? TransactionAmountEntity })
                .compactMap(Transaction.Amount.with(transactionAmountEntity:)),
              !amounts.isEmpty else {
            return nil
        }

        let description = transactionEntity.contentDescription

        return try .init(
            id: identifier,
            description: description,
            date: date,
            amounts: amounts
        )
    }
}

private extension Transaction.Amount {

    static func with(transactionAmountEntity: TransactionAmountEntity) throws -> Self? {
        guard let amount = transactionAmountEntity.amount,
              let budgetKind = transactionAmountEntity.budgetKind,
              let budgetIdentifier = transactionAmountEntity.budgetIdentifier,
              let sliceIdentifier = transactionAmountEntity.sliceIdentifier else {
            return nil
        }

        let kind: Budget.Kind = {
            switch budgetKind {
            case "income":
                return .income
            case "epxense":
                return .expense
            default:
                return .expense
            }
        }()

        return Transaction.Amount(
            amount: .value(amount.decimalValue),
            budgetKind: kind,
            budgetIdentifier: budgetIdentifier,
            sliceIdentifier: sliceIdentifier
        )
    }
}
