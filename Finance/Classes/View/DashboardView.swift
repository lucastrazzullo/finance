//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView<StorageProviderType: StorageProvider & ObservableObject>: View {

    @StateObject var storageProvider: StorageProviderType

    private let totalStatements: MoneyValue = .value(10000)
    private let totalTransactions: MoneyValue = .value(10000)

    var body: some View {
        NavigationView {
            VStack {

                HStack {
                    AmountCollectionItem(
                        title: "Total",
                        caption: "as of Friday 12 Oct",
                        amount: totalTransactions,
                        color: Color(UIColor.systemGroupedBackground)
                    )
                }
                .padding()

                List {
                    NavigationLink(destination: ReportView(storageProvider: storageProvider)) {
                        Text("Budgets")
                    }
                    .accessibilityIdentifier(AccessibilityIdentifier.DashboardView.budgetsLink)

                    NavigationLink(destination: CategorisedTransactionsView(repository: Repository(storageProvider: storageProvider)).navigationTitle("Transactions 2022")) {
                        Text("Transactions")
                    }
                }
            }
            .navigationTitle("Finance 2022")
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(storageProvider: MockStorageProvider())
    }
}
