//
//  BudgetOverviewView.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

struct BudgetOverviewView: View {

    let title: String
    let incoming: [Budget] = Mocks.incomingBudgetList
    let expenses: [Budget] = Mocks.expensesBudgetList

    var body: some View {
        List {
            Section(header: Text("Incoming")) {
                ForEach(incoming) { budget in
                    NavigationLink(destination: BudgetView(budget: budget)) {
                        AmountListItem(label: budget.name, amount: budget.totalAmount)
                    }
                }
            }

            Section(header: Text("Expenses")) {
                ForEach(expenses) { budget in
                    NavigationLink(destination: BudgetView(budget: budget)) {
                        AmountListItem(label: budget.name, amount: budget.totalAmount)
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}

// MARK: - Previews

struct BudgetsView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetOverviewView(title: "Predictions 2022")
    }
}
