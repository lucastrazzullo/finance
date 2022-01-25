//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    enum Sheet: Identifiable {
        case error(DomainError)
        case addNewBudgetSlice

        var id: String {
            switch self {
            case .error(let error):
                return error.localizedDescription
            case .addNewBudgetSlice:
                return "newBudgetSlice"
            }
        }
    }

    @State private var sheet: Sheet?

    @ObservedObject private var controller: BudgetController

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
                    if controller.budget.slices.count > 0 {
                        ForEach(controller.budget.slices) { slice in
                            HStack {
                                AmountListItem(label: slice.name, amount: slice.amount)
                                Text(makePercentageStringFor(amount: slice.amount)).font(.caption)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    controller.delete(slice: slice) { result in
                                        if case let .failure(error) = result {
                                            sheet = .error(error)
                                        }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } else {
                        Text("No slices defined for this budget")
                    }

                    Button(action: { sheet = .addNewBudgetSlice }) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Label("Rename", systemImage: "square.and.pencil")
            }
        }
        .sheet(item: $sheet) { presentingSheet in
            switch presentingSheet {
            case .error(let error):
                makeErrorView(error: error)
            case .addNewBudgetSlice:
                makeAddNewBudgetSliceView()
            }
        }
        .navigationTitle(controller.budget.name)
    }

    // MARK: - Private factory methods

    @ViewBuilder private func makeErrorView(error: DomainError) -> some View {
        ErrorView(error: error, options: [.retry], onSubmit: { option in
            sheet = .addNewBudgetSlice
        })
    }

    @ViewBuilder private func makeAddNewBudgetSliceView() -> some View {
        NewBudgetSliceView { slice in
            controller.add(slice: slice) { result in
                switch result {
                case .success:
                    sheet = nil
                case .failure(let error):
                    sheet = .error(error)
                }
            }
        }
    }

    private func makePercentageStringFor(amount: MoneyValue) -> String {
        let percentage = NSDecimalNumber(decimal: amount.value * 100 / controller.budget.amount.value).floatValue
        return "\(percentage)%"
    }

    // MARK: - Object life cycle

    init(budget: Budget, budgetProvider: BudgetProvider) {
        self.controller = BudgetController(budget: budget, budgetProvider: budgetProvider)
    }
}

// MARK: - Previews

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        let budgetProvider = MockBudgetProvider()
        NavigationView {
            BudgetView(budget: Mocks.budgets.last!, budgetProvider: budgetProvider)
        }
        .preferredColorScheme(.dark)
    }
}
