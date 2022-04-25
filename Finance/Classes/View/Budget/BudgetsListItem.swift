//
//  BudgetsListItem.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/04/2022.
//

import SwiftUI

struct BudgetsListItem: View {

    let budget: Budget

    var body: some View {
        HStack {
            Label(budget.name, systemImage: budget.icon.rawValue)
                .symbolRenderingMode(.hierarchical)
                .font(.body.bold())
                .accentColor(.secondary)
            Spacer()
            AmountView(amount: budget.amount)
        }
        .padding(.vertical, 8)
    }
}

struct BudgetsListItem_Previews: PreviewProvider {
    static var previews: some View {
        BudgetsListItem(budget: Mocks.budgets[0])
    }
}
