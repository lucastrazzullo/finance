//
//  FinanceApp.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

@main struct FinanceApp: App {

    @StateObject var finance: Finance = {
        let storageProvider: StorageProvider = {
            if CommandLine.arguments.contains("testing") {
                return MockStorageProvider()
            } else {
                return CoreDataStorageProvider()
            }
        }()

        return Finance(storageProvider: storageProvider)
    }()

    var body: some Scene {
        WindowGroup {
            FinanceView(finance: finance, year: 2022)
        }
    }
}
