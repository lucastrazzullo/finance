//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView: View {

    @StateObject private var storageProvider: StorageProvider = StorageProvider()

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
                    NavigationLink(destination: BudgetsView(storageProvider: storageProvider.budgetProvider).navigationTitle("Budgets 2022")) {
                        Text("Budgets")
                    }

                    NavigationLink(destination: CategorisedTransactionsView().navigationTitle("Transactions 2022")) {
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
        DashboardView()
    }
}
