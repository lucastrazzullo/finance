//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView: View {

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: BudgetsView().navigationTitle("Budgets 2022")) {
                    Text("Budgets")
                }

                NavigationLink(destination: CategorisedTransactionsView().navigationTitle("Transactions 2022")) {
                    Text("Transactions")
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
