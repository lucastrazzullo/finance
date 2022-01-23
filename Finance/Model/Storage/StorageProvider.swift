//
//  StorageProvider.swift
//  Finance
//
//  Created by Luca Strazzullo on 22/01/2022.
//

import CoreData

final class StorageProvider: ObservableObject {

    private static let storageContainerName = "Finance"

    private let persistentContainer: NSPersistentContainer

    lazy var budgetProvider: BudgetProvider = {
        BudgetStorageProvider(persistentContainer: persistentContainer)
    }()

    init() {
        persistentContainer = NSPersistentContainer(name: Self.storageContainerName)
        persistentContainer.loadPersistentStores(completionHandler: { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
            }
        })
    }
}
