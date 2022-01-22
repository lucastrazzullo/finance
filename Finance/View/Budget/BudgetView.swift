//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    final class Controller: ObservableObject {

        let budget: Budget

        var monthlyAmount: MoneyValue {
            budget.amount
        }

        var yearlyAmount: MoneyValue {
            budget.amount * .value(12)
        }

        init(budget: Budget) {
            self.budget = budget
        }

        func slicePercentage(amount: MoneyValue) -> Float {
            NSDecimalNumber(decimal: amount.value * 100 / budget.amount.value).floatValue
        }
    }

    @ObservedObject private var controller: Controller

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AmountCollectionItem(
                title: "Monthly",
                caption: "\(controller.yearlyAmount.value) per year",
                amount: controller.monthlyAmount,
                color: .gray.opacity(0.3)
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 12)

            List {
                Section(header: Text("Slices")) {
                    ForEach(controller.budget.slices) { slice in
                        if controller.budget.slices.count > 0 {
                            HStack {
                                AmountListItem(label: slice.name, amount: slice.amount)
                                Text(makePercentageStringFor(amount: slice.amount)).font(.caption)
                            }
                        } else {
                            Text("No slices defined for this budget")
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationTitle(controller.budget.name)
    }

    // MARK: - Private helper methods

    private func makePercentageStringFor(amount: MoneyValue) -> String {
        return "\(controller.slicePercentage(amount: amount))%"
    }

    // MARK: - Object life cycle

    init(budget: Budget) {
        self.controller = Controller(budget: budget)
    }
}

// MARK: - Previews

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BudgetView(budget: Mocks.budgets.first!)
        }
        .preferredColorScheme(.dark)
    }
}
