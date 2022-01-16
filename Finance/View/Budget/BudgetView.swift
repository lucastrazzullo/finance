//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    let budget: Budget

    private var category: Category {
        Mocks.categories.first(where: { $0.id == budget.category })!
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AmountCollectionItem(
                title: "Monthly",
                caption: "\(budget.amount.value * 12) per year",
                amount: budget.amount,
                color: .gray.opacity(0.7)
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 12)

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
        .navigationTitle(category.name)
    }
}

// MARK: - Previews

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BudgetView(budget: Mocks.outgoingBudgetList.first!)
        }
    }
}
