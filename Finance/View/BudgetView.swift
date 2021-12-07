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
        List {
            ForEach(budget.baskets) { basket in
                AmountListItem(label: basket.description, amount: basket.amount)
            }
        }
        .navigationTitle(budget.name)
    }
}

// MARK: - Previews

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BudgetView(budget: Budget(name: "Budget", baskets: Mocks.baskets))
        }
    }
}
