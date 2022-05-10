//
//  FinanceApp.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

@main struct FinanceApp: App {

    @Environment(\.storageProvider) private var storageProvider

    var body: some Scene {
        WindowGroup {
            FinanceView(viewModel: .init(year: 2022, storageProvider: storageProvider))
        }
    }
}

// MARK: - Environment

private struct StorageProviderKey: EnvironmentKey {
    static let defaultValue: StorageProvider = {
        if CommandLine.arguments.contains("testing") {
            return MockStorageProvider()
        } else {
            return CoreDataStorageProvider()
        }
    }()
}

extension EnvironmentValues {
    var storageProvider: StorageProvider {
        get { return self[StorageProviderKey.self] }
        set { self[StorageProviderKey.self] = newValue }
    }
}
