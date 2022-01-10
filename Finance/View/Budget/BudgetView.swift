//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    let budget: Budget

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                if let category = Mocks.categories.first(where: { $0.id == budget.category }) {
                    HStack {
                        Text("Category:")
                        Text(category.name).bold()
                    }
                }

                HStack {
                    Text("Monthly cap:")
                    AmountView(amount: budget.amount)
                }

                HStack {
                    Text("Yearly cap:")
                    AmountView(amount: .value(budget.amount.value * 12))
                }
            }
            .padding()

            let subcategories = Mocks.subcategories.filter({ $0.category == budget.category })
            if !subcategories.isEmpty {
                List {
                    Section(header: Text("Subcategories")) {
                        ForEach(subcategories) { subcatecory in
                            Text(subcatecory.name)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(budget: Mocks.outgoingBudgetList.first!)
    }
}
