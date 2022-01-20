//
//  BudgetsView.swift
//  Finance
//
//  Created by luca strazzullo on 3/11/21.
//

import SwiftUI

struct BudgetsView: View {

    let incoming: [Budget] = BudgetProvider.incomingBudgetList
    let expenses: [Budget] = BudgetProvider.expensesBudgetList

    var body: some View {
        List {
            Section(header: Text("Incoming (monthly)")) {
                ForEach(incoming) { budget in
                    NavigationLink(destination: BudgetView(budget: budget)) {
                        AmountListItem(label: budget.name, amount: budget.amount)
                    }
                }
            }

            Section(header: Text("Expenses (monthly)")) {
                ForEach(expenses) { budget in
                    NavigationLink(destination: BudgetView(budget: budget)) {
                        AmountListItem(label: budget.name, amount: budget.amount)
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct BudgetsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BudgetsView().navigationTitle("Budgets")
        }
    }
}
